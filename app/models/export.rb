require 'csv'

class Export
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true

  def process_file!
    read_file = File.read(self.file.tempfile) 
  
    file_splited = read_file.to_s.split("Delivery-date: ")

    array = []
    re = /<("[^"]*"|'[^']*'|[^'">])*>/

    @row =""
    
    CSV.generate(headers: false, col_sep: ";") do |csv|
      csv << ['data','nome','telefone']
      file_splited.each_with_index do |line, index|
        date  = line[6..25] rescue nil
        name  = line.split("Nome: ")[1].split("</p>")[0] rescue nil
        tel   = line.split("Celular com DDD:")[1].split("</div>")[0].gsub(".","").gsub(" ","").gsub("(","").gsub(")","").gsub("-","") rescue nil
        
        next if (date.nil? || name.nil?) 
        next if name.length > 200
        @row = "#{name.to_s.mb_chars.upcase}&#{tel}\n" rescue nil

        csv << [date, name.to_s.mb_chars.upcase, tel]
      end
      
    end
  end
end