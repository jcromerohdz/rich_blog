class Article < ApplicationRecord
	has_rich_text :content
	belongs_to :user
	has_many :has_categories
	has_many :categories, through: :has_categories
	attr_accessor :category_elements

  def save_categories
		# category_elemnts 1,2,3
		# Change the elements to an array
    # categories_array = category_elements.split(",")
		# Loop the array
		return has_categories.destroy_all if category_elements.nil? || category_elements.empty?
		has_categories.where.not(category_id: category_elements).destroy_all 
		category_elements.each do |category_id|
		  # Create HasCategory
			HasCategory.find_or_create_by(article: self, category_id: category_id)
		end
	end
end
