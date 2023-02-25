import Foundation
import API

extension AppModels.InvolvedCompany.Company {
	init(_ company: InvolvedCompany.Company) {
		self.id = company .id
		self.name = company.name
		self.developed = company.developed
		self.logo = company.logo
		self.description = company.description
	}
}
