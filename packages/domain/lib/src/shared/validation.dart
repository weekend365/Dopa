String requireNonBlank(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'Must not be blank.');
  }
  return value;
}

DateTime requireUtc(DateTime value, String name) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, name, 'Must be a UTC DateTime.');
  }
  return value;
}

int requirePositive(int value, String name) {
  if (value <= 0) {
    throw ArgumentError.value(value, name, 'Must be greater than zero.');
  }
  return value;
}
