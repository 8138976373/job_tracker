/// A minimal, explicit service locator. Register long-lived app services once.
final class ServiceLocator {
  final Map<Type, Object> _instances = {};

  void registerSingleton<T extends Object>(T instance) {
    if (_instances.containsKey(T))
      throw StateError('$T is already registered.');
    _instances[T] = instance;
  }

  T get<T extends Object>() {
    final instance = _instances[T];
    if (instance == null) throw StateError('$T has not been registered.');
    return instance as T;
  }

  void reset() => _instances.clear();
}
