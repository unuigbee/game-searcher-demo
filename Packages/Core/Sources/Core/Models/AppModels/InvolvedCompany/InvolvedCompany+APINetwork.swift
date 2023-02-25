import Foundation
import API

extension AppModels.InvolvedCompany {
	init(_ involvedCompany: InvolvedCompany) {
		self.id = involvedCompany.id
		self.company = AppModels.InvolvedCompany.Company.init(involvedCompany.company)
		self.publisher = involvedCompany.publisher
		self.developer =  involvedCompany.developer
		self.supporting = involvedCompany.supporting
	}
}
