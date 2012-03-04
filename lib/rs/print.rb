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

  # Resize the first column so that the rest of the table to be placed in the center of the given area.
  def self.place_table_into_center(column_widths, pdf)
    tbl_width = column_widths.inject {|sum, n| sum + n }
    column_widths[0] = (pdf.bounds.width - tbl_width) / 2
    column_widths
  end

  def self.render_waybill(waybill, pdf)
    pdf.change_font :default, DEF_FONT_SIZE
    render_cell_01(waybill, pdf)
    pdf.move_down 5
    render_cell_02_and_03(waybill, pdf)
    pdf.move_down 10
    render_cells_04_and_05(waybill, pdf)
    pdf.move_down 5
    
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

  def self.tax_code_box(pdf, title, number, tax_code, caption_width = 90)
    tax_chars = empty?(tax_code) ? [' '] * 11 : tax_code.split(//)
    tax_chars = tax_chars[0..11] if tax_chars.size > 11
    items = [[title, number, ''] + tax_chars]
    widths = [caption_width, NUM_CELL_WIDTH, 5] + ([12] * tax_chars.size)
    pdf.make_table(items, :cell_style => {:padding => 4, :align => :center}, :column_widths => widths) do
      column(0).style(:align => :left, :borders => [])
      column(1).style({:background_color => HIGHLIGHT})
      column(2).style(:borders => [])
    end
  end

end
