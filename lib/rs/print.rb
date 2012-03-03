# -*- encoding : utf-8 -*-

require 'c12-commons'

module RS

  class WaybillPDF < C12::PDF::Document
  end

  def self.print_waybill(waybill, file)
    WaybillPDF.generate file, :page_size => 'A4', :margin => [15, 15] do |pdf|
      # TODO: adding some syntax here
      render_waybill waybill, pdf
    end
  end

  private

  HIGHLIGHT = 'eeeeee'

  def self.render_waybill(waybill, pdf)
    pdf.change_font :default, 8
    render_cell1(waybill, pdf)
  end

  def self.render_cell1(waybill, pdf)
    items = [['სასაქონლო ზედნადები №', '1', '', waybill.number]]
    tbl = pdf.make_table items, :cell_style => {:padding => 4, :align => :center}, :column_widths => [250, 15, 5, 100] do
      column(0).style({:align => :right, :borders => []})
      column(1).style({:background_color => HIGHLIGHT})
      column(2).style({:borders => []})
    end
    tbl.draw
  end

end
