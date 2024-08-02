const globals = {};

export function set(key, value) {
  globals[key] = value;
}

export function get(key) {
  return globals[key];
}
