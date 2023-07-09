import { JSON } from "@w3bstream/wasm-sdk";

export function getPayloadValue(message: string): JSON.Obj {
  return JSON.parse(message) as JSON.Obj;
}

export function getField<T extends JSON.Value>(
  data: JSON.Obj,
  field: string
): T | null {
  return data.get(field) as T;
}

export function getIntegerField(
  data: JSON.Obj,
  field: string,
  defaultValue: i64 = 0
): i64 {
  const val = getField<JSON.Integer>(data, field);
  if (val === null) {
    return defaultValue
  };
  return val.valueOf();
}

export function getStringField(
  data: JSON.Obj,
  field: string,
  defaultValue: string | null = ""
): string | null {
  const val = getField<JSON.Str>(data, field);
  if (val === null) {
    return defaultValue
  };
  return val.valueOf();
}

export function getFloatField(
  data: JSON.Obj,
  field: string,
  defaultValue: f64 | null = 0.0
): f64 | null {
  const val = getField<JSON.Float>(data, field);
  if (val === null) {
    return defaultValue
  };
  return val.valueOf();
}

