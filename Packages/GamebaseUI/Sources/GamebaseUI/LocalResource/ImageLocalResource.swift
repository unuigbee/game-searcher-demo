public enum ImageLocalResource: Hashable {
	case system(String)
	case name(String)
}

public extension ImageLocalResource {
	var imageName: String {
		switch self {
		case let .system(name):
			return name
		case let .name(name):
			return name
		}
	}
}
