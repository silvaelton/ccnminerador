require 'csv'

class Export
  include ActiveModel::Model

  attr_accessor :file

  validates :file, presence: true

  def process_file!
    read_file = File.read(self.file.tempfile) 
  
    file_splited = read_file.to_s.split("Envelope-to")

    array = []
    re = /<("[^"]*"|'[^']*'|[^'">])*>/

    @row =""

    CSV.generate(headers: false, col_sep: ";") do |csv|
      csv << ['data','nome','cpf','telefone','email','cpf_valido']
      file_splited.each_with_index do |line, index|
        date  = line.split("Delivery-date:")[1][6..25] rescue 'nao identificada'
       
        table_split = line.split("Nome: ")[2].split("\r\n") rescue nil
    
        next if table_split.nil? || date.nil?
        
        name  = "#{table_split[0].strip}" rescue 'nao informado'
        cpf   = "#{table_split[1].gsub!('CPF: ', '').gsub("-","").gsub(" ","").gsub(".","").gsub("i","").strip}" rescue 'nao informado'
        tel   = "#{table_split[2].gsub!('Celular com DDD: ','').strip}" rescue 'nao informado'
        email = "#{table_split[3].gsub!('Email: ', '').strip}" rescue 'nao informado'
    
        @row = "#{name}&#{cpf}&#{tel}&#{email}\n" rescue nil

        csv << [date, name, cpf, tel, email, (CPF.valid?(cpf) ? "CPF VALIDO" : "CPF INVALIDO")]
      end
      
    end
  end
end