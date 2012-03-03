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

  def self.render_waybill(waybill, pdf)
    pdf.change_font :default, 7
    render_cell_01(waybill, pdf)
  end

  def self.render_cell_01(waybill, pdf)
    items = [['', '1', 'სასაქონლო ზედნადები №', waybill.number]]
    cols = [0, 18, 120, 100]
    cols_width = cols.inject {|sum, n| sum + n }
    cols[0] = (pdf.bounds.width - cols_width) / 2 # place table in center
    tbl = pdf.make_table items, :cell_style => {:padding => 4, :align => :center}, :column_widths => cols do
      column(0).style({:borders => []})
      column(1).style({:background_color => HIGHLIGHT})
      column(2).style({:borders => []})
    end
    tbl.draw
  end

end
