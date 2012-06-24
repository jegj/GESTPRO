# -*- encoding : utf-8 -*-
class DocenteMateria < ActiveRecord::Base
	set_primary_keys  :docente_cedula , :materia_id
	belongs_to :materia
	belongs_to :docente , :foreign_key => :docente_cedula

	validates :docente_cedula ,:materia_id ,:presence=> true

	def self.busca_docente_materia(docente_cedula,materia_id)
		DocenteMateria.where(:docente_cedula =>docente_cedula ,:materia_id => materia_id).first
	end
end
