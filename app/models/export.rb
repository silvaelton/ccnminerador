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
      csv << ['data','nome','cpf','telefone','email','cpf_valido']
      file_splited.each_with_index do |line, index|
        date  = line[6..25] rescue 'nao identificada'
        
        if line.split("Content preview:").count > 1
          table_split = line.split("Nome: ")[2].split("<br>") rescue nil
        else
          table_split = line.split("Nome: ")[1].split("<br>") rescue nil
        end
        
        next if table_split.nil? || date.nil?
        
        if table_split[0].split('</p>').count > 1
          
          table_split_p = table_split[0].split('</p>')
          name  = "#{table_split_p[0].strip}" rescue 'nao informado'
          cpf   = "#{table_split_p[1].gsub('CPF: ', '').gsub("<p>","").gsub("-","").gsub(" ","").gsub(".","").gsub("i","").gsub('</p>','').strip}" rescue 'nao informado'
          tel   = "#{table_split_p[3].split('<div>')[1].gsub("(","").gsub(")","").gsub('-','').gsub('Celular com DDD: ','').gsub("</div>","").gsub(" ","").strip}" rescue 'nao informado'
          email = "#{table_split_p[3].split('<div>')[2].gsub('Email: ', '').gsub('<p>', '').strip}" rescue 'nao informado'    
              
        else
          if table_split[0].length > 100
            table_split = table_split[0].split("\r\n")
          end

          name  = "#{table_split[0].strip}" rescue 'nao informado'
          cpf   = "#{table_split[1].gsub('CPF: ', '').gsub("<p>","").gsub("-","").gsub(" ","").gsub(".","").gsub("i","").strip}" rescue 'nao informado'
          tel   = "#{table_split[2].to_s.gsub('Celular com DDD: ','').gsub("(","").gsub(")","").gsub('-','').gsub("<p>","").gsub(" ","").strip}" rescue 'nao informado'
          email = "#{table_split[3].to_s.gsub('E-mail: ', '').gsub('Email: ', '').strip}" rescue 'nao informado'
        end

        @row = "#{name.to_s.mb_chars.upcase}&#{cpf}&#{tel}&#{email}\n" rescue nil

        csv << [date, name, cpf, tel, email, (CPF.valid?(cpf) ? "CPF VALIDO" : "CPF INVALIDO")]
      end
      
    end
  end
end