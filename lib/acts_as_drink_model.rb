# ActsAsEnglishWelsh
require 'active_record'

module ActiveRecord
  module Acts
    module DrinkModel
      def self.included(base)
         base.extend(ClassMethods)
       end

       module ClassMethods
         def acts_as_drink_model(options = {})    
           validates :en_name, :presence => true, :length => { :within => 1..255, :allow_blank => true }
           validates :cy_name, :length => { :within => 1..255, :allow_blank => true }
           
           attr_accessor :switch_link
           
           scope :enabled, where(:enabled => true)
           scope :disabled, where(:enabled => false)
           
           before_validation :strip_blanks
           send :include, InstanceMethods
         end
         
         def name_order(dir = :asc)
           locale_name = (I18n.locale == :cy) ? 'cy_name' : 'en_name'
           dir = (dir == :desc or dir == 'DESC') ? 'DESC' : 'ASC'
           order("#{self.table_name}.#{locale_name} #{dir}")
         end
      end
        
      module InstanceMethods            
         def strip_blanks
           self.en_name.strip! if self.en_name
           self.cy_name.strip! if self.cy_name
           
           self.en_name = nil if self.en_name.blank?
           self.cy_name = nil if self.cy_name.blank?
         end
                  
         def name=(str)
           self.en_name = str
         end
                  
         def name
           if I18n.locale == :cy
             self.cy_name.present? ? self.cy_name : "#{self.en_name} (en)"
           else  
             self.en_name
           end
         end
      end

    end
  end
end

