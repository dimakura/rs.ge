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
  SMALL_FONT_SIZE = 5

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

  # Resize the first column so that the rest of the table to be placed in the center of the given area.
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
      columns(0).style(:size => opts[:caption_size]) if opts[:caption_size]
    end
    table
  end

end
