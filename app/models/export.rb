require 'csv'

class Export
  include ActiveModel::Model

  attr_accessor :file, :version_one

  validates :file, presence: true

  def process_file!

    if self.version_one == "1"
      process_file_older!
    else

      read_file = File.read(self.file.tempfile) 
    
      file_splited = read_file.to_s.split("Delivery-date: ")

      array = []
      re = /<("[^"]*"|'[^']*'|[^'">])*>/

      @row =""
      
      CSV.generate(headers: false, col_sep: ";") do |csv|
        csv << ['data','nome','cpf','telefone']
        file_splited.each_with_index do |line, index|
          next if index == 0
          date  = line[5..24] rescue nil
          name  = line.split("Nome: ")[1].split("</p>")[0] rescue nil
          cpf   = line.split("CPF: ")[1].split("</p>")[0].to_s.strip.gsub(";","") rescue nil
          if cpf.nil?
            cpf = line.split("CPF:&nbsp")[1].split("</p>")[0].to_s.strip.gsub(";","") rescue nil
          end
          tel   = line.split("Celular com DDD:")[1].split("</p>")[0].strip rescue nil
          
          next if (date.nil? || name.nil?) 
          next if name.length > 200
          @row = "#{name.to_s.upcase}&#{tel.gsub('</div>','')}\n" rescue nil

          csv << [date, name.to_s.mb_chars.upcase, cpf, tel]
        end
        
      end
    end
  end

  def process_file_older
    read_file = File.read(self.file.tempfile) 

    file_splited = read_file.to_s.split("X-Mailer: PHPMailer 6.4.1 (https://github.com/PHPMailer/PHPMailer)")

    array = []
    re = /<("[^"]*"|'[^']*'|[^'">])*>/

    @row =""

    CSV.generate(headers: false, col_sep: ";") do |csv|
      csv << ['data','nome','cpf','telefone','email','cpf_valido']
      file_splited.each_with_index do |line, index|
        date  = line.split("Delivery-date:")[1][6..25] rescue 'nao identificada'
        table = line.split('<table>')[1] rescue nil

        next if table.nil?

        table_split = table.split("\r\n")

        name  = "#{table_split[3].gsub!(re, '').strip}" rescue 'nao informado'
        cpf   = "#{table_split[7].gsub!(re, '').strip.gsub("-","").gsub(" ","").gsub(".","").gsub("i","")}" rescue 'nao informado'
        tel   = "#{table_split[11].gsub!(re, '').strip}" rescue 'nao informado'
        email = "#{table_split[15].gsub!(re, '').strip}" rescue 'nao informado'

        @row = "#{name}&#{cpf}&#{tel}&#{email}\n"

        csv << [date, name, cpf, tel, email, (CPF.valid?(cpf) ? "CPF VALIDO" : "CPF INVALIDO")]
      end
    end
  end
end