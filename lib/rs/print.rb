# -*- encoding : utf-8 -*-

require 'c12-commons'

module RS

  class WaybillPDF < C12::PDF::Document
  end

  def self.print_waybill(waybill, file)
    WaybillPDF.generate file, :page_size => 'A4', :margin => [15, 15] do |pdf|
      render_waybill waybill, pdf
    end
  end

  private

  HIGHLIGHT = 'eeeeee'
  NUM_CELL_WIDTH = 18
  DEF_FONT_SIZE = 7
  SMALLER_FONT_SIZE = 6
  SMALL_FONT_SIZE = 5
  FOOTER_HEIGHT = 250

  def self.render_waybill(waybill, pdf)
    pdf.change_font :default, DEF_FONT_SIZE
    render_cell_01(waybill, pdf)
    pdf.move_down 10
    render_cell_02_and_03(waybill, pdf)
    pdf.move_down 10
    render_cells_04_and_05(waybill, pdf)
    pdf.move_down 10
    render_cells_06_07_and_08(waybill, pdf)
    pdf.move_down 10
    render_cells_09_and_10(waybill, pdf)
    pdf.move_down 10
    render_cells_11_and_12(waybill, pdf)
    pdf.move_down 20
    # items
    pdf.change_font :serif, DEF_FONT_SIZE + 2
    pdf.text 'სასაქონლო ზედნადების ცხრილი', :align => :center
    pdf.move_down 10
    pdf.change_font :default, DEF_FONT_SIZE
    last_index = render_items waybill, 0, pdf
    # footer
    pdf.move_down 5
    render_footer(waybill, pdf)
  end

  def self.render_cell_01(waybill, pdf)
    items = [['', 'სასაქონლო ზედნადები №', '1', '', waybill.number]]
    cols = place_table_into_center [0, 150, NUM_CELL_WIDTH, 5, 100], pdf
    tbl = pdf.make_table items, :cell_style => {:padding => 4, :align => :center}, :column_widths => cols do
      column(0..1).style(:borders => [], :align => :left, :size => DEF_FONT_SIZE + 2)
      column(2).style(:background_color => HIGHLIGHT)
      column(3).style(:borders => [])
    end
    tbl.draw
  end

  def self.render_cell_02_and_03(waybill, pdf)
    items1 = [['', '2', '', C12::KA.format_date(waybill.activate_date), '', '3', '', waybill.activate_date.strftime('%H:%M')]]
    items2 = [['', '', 'თარიღი (რიცხვი, თვე, წელი)', '', '', 'დრო (საათი, წუთი)']]
    cols1 = place_table_into_center [0, NUM_CELL_WIDTH, 5, 80, 32, NUM_CELL_WIDTH, 5, 80], pdf
    cols2 = place_table_into_center [0, NUM_CELL_WIDTH + 5, 80, 32, NUM_CELL_WIDTH + 5, 80], pdf
    tbl1 = pdf.make_table items1, :cell_style => {:padding => 4, :align => :center}, :column_widths => cols1 do
      column(0).style({:borders => []})
      column(1).style({:background_color => HIGHLIGHT})
      column(2).style({:borders => []})
      column(4).style({:borders => []})
      column(5).style({:background_color => HIGHLIGHT})
      column(6).style({:borders => []})
    end
    tbl2 = pdf.make_table items2, :cell_style => {:padding => 1, :align => :center, :borders => [], :size => SMALL_FONT_SIZE}, :column_widths => cols2
    tbl1.draw
    tbl2.draw
  end

  def self.render_cells_04_and_05(waybill, pdf)
    tbl1 = tax_code_box(pdf, 'გამყიდველი (გამგზავნი)', '4', waybill.seller_tin)
    tbl2 = tax_code_box(pdf, 'მყიდველი (მიმღები)', '5', waybill.buyer_tin)
    items = [[tbl1, '', tbl2]]
    widths = [tbl1.width, pdf.bounds.width/2 - tbl1.width, tbl2.width]
    pdf.table items, :cell_style => {:padding => 0, :borders => []}, :column_widths => widths
    pdf.move_down 5
    items = [[nvl(waybill.seller_name, ''), '', nvl(waybill.buyer_name, '')], ['დასახელება, ან სახელი და გვარი', '', 'დასახელება, ან სახელი და გვარი']]
    pdf.table items, :cell_style => {:padding => 0, :borders => [], :align => :center}, :column_widths => [pdf.bounds.width/2 - 5, 10, pdf.bounds.width/2 - 5] do
      row(0).style(:borders => [:bottom], :padding => 5, :size => DEF_FONT_SIZE + 1)
      column(1).style(:borders => [])
      row(1).style(:size => SMALL_FONT_SIZE)
    end
  end

  def self.render_cells_06_07_and_08(waybill, pdf)
    items1 = [['6', 'ოპერაციის შინაარსი', RS::WaybillType::NAMES[waybill.type]]]
    tbl1 = pdf.make_table items1, :cell_style => {:align => :center}, :column_widths => [NUM_CELL_WIDTH, 70, 100] do
      column(0).style(:background_color => HIGHLIGHT)
      column(1).style(:borders => [], :size => DEF_FONT_SIZE - 1)
    end
    items2 = [['7', '', waybill.start_address], ['', '', 'ტრანსპორტირების დაწყების ადგილი (მისამართი)'],
              ['8', '', waybill.end_address  ], ['', '', 'ტრანსპორტირების დასრულების ადგილი (მისამართი)']]
    tbl2 = pdf.make_table items2, :column_widths => [NUM_CELL_WIDTH, 5, pdf.bounds.width - NUM_CELL_WIDTH - 5 - 10 - tbl1.width] do
      column(0).style(:align => :center)
      column(1).style(:borders => [])
      column(0).row(0).style(:background_color => HIGHLIGHT)
      column(0).row(2).style(:background_color => HIGHLIGHT)
      row(1).style(:align => :center, :size => SMALL_FONT_SIZE, :padding => [0, 0, 5, 0], :borders => [])
      row(3).style(:align => :center, :size => SMALL_FONT_SIZE, :padding => 0, :borders => [])
    end
    pdf.table [[tbl1, '', tbl2]], :column_widths => [nil, 10, nil], :cell_style => {:borders => []}
  end

  def self.render_cells_09_and_10(waybill, pdf)
    items = [['', '9', '', RS::TransportType::NAMES[waybill.transport_type_id], '', '10', '', waybill.car_number],
             ['', '',  '', 'ტრანსპორტირების სახე', '', '', '', 'სატრანსპორტო საშუალების სახელმწიფო ნომერი']]
    column_widths = place_table_into_center [0, NUM_CELL_WIDTH, 5, 120, 10, NUM_CELL_WIDTH, 5, 120], pdf
    pdf.table items, :column_widths => column_widths, :cell_style => {:align => :center, :padding => 4} do
      column(0).style(:borders => [])
      column(2).style(:borders => [])
      column(4).style(:borders => [])
      column(6).style(:borders => [])
      row(0).column(1).style(:background_color => HIGHLIGHT)
      row(0).column(5).style(:background_color => HIGHLIGHT)
      row(1).style(:size => SMALL_FONT_SIZE, :borders => [], :padding => 0)
    end
  end

  def self.render_cells_11_and_12(waybill, pdf)
    t11 = tax_code_box(pdf, 'სატრანსპორტო საშუალების მძღოლის პირადი ნომერი', '11', waybill.driver_tin, :caption_size => DEF_FONT_SIZE - 1)
    t12A = pdf.make_table [['12', '', number_format(waybill.transportation_cost)], ['', '', 'თანხა ლარებში']], :column_widths => [NUM_CELL_WIDTH, 5, 100], :cell_style => {:padding => 4, :align => :center} do
      column(1).style(:borders => [])
      column(0).row(0).style(:background_color => HIGHLIGHT)
      row(1).style(:borders => [], :size => SMALL_FONT_SIZE, :padding => 0)
    end
    t12 = pdf.make_table [['გამყიდველის (გამგზავნის) / მყიდველის (მიმღების) მიერ გაწეული ტრანსპორტირების ხარჯი', t12A]], :cell_style => {:borders => [], :padding => 0}, :column_widths => [150] do
      column(0).style(:size => DEF_FONT_SIZE - 1)
    end
    pdf.table [[t11, '', t12]], :cell_style => {:borders => []}
  end

  def self.render_items(waybill, from, pdf)
    col_widths = [20, pdf.bounds.width - 20 - 55*5, 55, 55, 55, 55, 55]
    items = [['№', 'საქონლის დასახელება', 'საქონლის კოდი', 'საქონლის ზომის ერთეული', 'საქონლის რაოდენობა', 'საქონლის ერთეულის ფასი*', 'საქონლის ფასი*'], ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII']]
    pdf.table items, :column_widths => col_widths, :cell_style => {:align => :center, :valign => :center, :size => SMALLER_FONT_SIZE} do
      row(1).style(:padding => 2)
    end
    index = from
    while true do
      item = waybill.items[index]
      item_table = render_item(index - from, item, col_widths, pdf)
      y = pdf.y - item_table.height
      if y > FOOTER_HEIGHT
        item_table.draw
      else
        break
      end
      index += 1
    end
    index
  end

  def self.render_item(num, item, widths, pdf)
    if item
      items = [[num + 1, item.prod_name, item.bar_code, item.unit_name, number_format(item.quantity, 5), number_format(item.price), number_format(item.quantity * item.price)]]
    else
      items = [[' ']*7]
    end
    pdf.make_table items, :column_widths => widths, :cell_style => {:size => SMALLER_FONT_SIZE} do
      column(0).style(:align => :right)
      column(2).style(:align => :center)
      column(3).style(:align => :center)
      column(4).style(:align => :right)
      column(5).style(:align => :right)
      column(6).style(:align => :right)
    end
  end

  def self.render_footer(waybill, pdf)
    render_cell_13(waybill, pdf)
    pdf.move_down 10
    render_cells_14_and_15(waybill, pdf)
    pdf.move_down 5
    render_cells_16_and_17(waybill, pdf)
    # TODO:
  end

  def self.render_cell_13(waybill, pdf)
    total = 0
    waybill.items.each {|item| total += item.price * item.quantity }
    items = [['13', '', "#{number_format total} ლარი", '', C12::KA::tokenize(total*1.0, :currency => 'ლარი', :currency_minor => 'თეთრი')]]
    pdf.table items, :column_widths => [NUM_CELL_WIDTH, 5, 120, 5, pdf.bounds.width - NUM_CELL_WIDTH - 130] do
      column(0).style(:background_color => HIGHLIGHT)
      column(1).style(:borders => [])
      column(2).style(:align => :center)
      column(3).style(:borders => [])
      column(4).style(:align => :center)
    end
    pdf.move_down 2
    pdf.text 'მიწოდებული საქონლის მთლიანი თანხა (ციფრებით და სიტყვიერად)', :align => :center, :size => SMALL_FONT_SIZE
  end

  def self.render_cells_14_and_15(waybill, pdf)
    items = [['14', '', waybill.seller_info, '', '15', '', waybill.buyer_info], ['','', 'გამყიდველი (გამგზავნი) / საქონლის ჩაბარებაზე უფლებამოსილი პირი (თანამდებობა, სახელი და გვარი)', '', '', '', 'მყიდველი (მიმღები), საქონლის ჩაბარებაზე უფლებამოსილი პირი (თანამდებობა, სახელი და გვარი)']]
    w = (pdf.bounds.width - 2 * NUM_CELL_WIDTH - 20) / 2
    pdf.table items, :column_widths => [NUM_CELL_WIDTH, 5, w, 10, NUM_CELL_WIDTH, 5, w], :cell_style => {:align => :center} do
      row(1).style(:borders => [], :size => SMALL_FONT_SIZE, :padding => 0)
      row(0).column(1).style(:borders => [])
      row(0).column(3).style(:borders => [])
      row(0).column(5).style(:borders => [])
      row(0).column(0).style(:background_color => HIGHLIGHT)
      row(0).column(4).style(:background_color => HIGHLIGHT)
    end
  end

  def self.render_cells_16_and_17(waybill, pdf)
    # TODO:
  end

  # Resize the first column so that the rest of the table to be placed in the center of the area.
  def self.place_table_into_center(column_widths, pdf)
    tbl_width = column_widths.inject {|sum, n| sum + n }
    column_widths[0] = (pdf.bounds.width - tbl_width) / 2
    column_widths
  end

  # Prepare table with tax code.
  def self.tax_code_box(pdf, title, number, tax_code, opts = {})
    # tax code table
    tax_chars = empty?(tax_code) ? [' '] * 11 : tax_code.split(//)
    tax_chars = tax_chars[0..11] if tax_chars.size > 11
    items = [[number, ''] + tax_chars]
    widths = [NUM_CELL_WIDTH, 5] + ([12] * tax_chars.size)
    t1 = pdf.make_table items, :cell_style => {:padding => 4, :align => :center}, :column_widths => widths do
      column(0).style({:background_color => HIGHLIGHT})
      column(1).style(:borders => [])
    end
    # combine with caption
    caption_width = opts[:caption_width] || 90
    table = pdf.make_table [[title, t1]], :cell_style => {:padding => 0, :borders => []}, :column_widths => [caption_width] do
      column(0).style(:valign => :center)
      column(0).style(:size => opts[:caption_size]) if opts[:caption_size]
    end
    table
  end

end
