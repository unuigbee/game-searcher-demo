public typealias EquatableIdentifier = Identifiable & Hashable

public enum ViewEntity<Type: EquatableIdentifier> {
	case entity(Type)
	case entityId(Type.ID)
}

extension ViewEntity: EquatableIdentifier {
	public var id: Type.ID {
		switch self {
		case let .entity(model): return model.id
		case let .entityId(id): return id
		}
	}
}

public extension ViewEntity {
	var entity: Type? {
		switch self {
		case let .entity(type): return type
		case .entityId: return nil
		}
	}
}
