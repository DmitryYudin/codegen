#include "validator_schemas.h"

namespace validator {
extern const std::unordered_map<std::string_view, const std::string_view> kSchemas = {
    {
        "/animal",
        R"(
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "is-alive",
                "type",
                "name",
                "age"
              ],
              "properties": {
                "id": {
                  "enum": [
                    "cat",
                    "dog"
                  ]
                },
                "is-alive": {
                  "type": "boolean"
                },
                "type": {
                  "type": "string",
                  "enum": [
                    "cat",
                    "dog"
                  ]
                },
                "name": {
                  "type": "string",
                  "minLength": 1
                },
                "nickname": {
                  "type": "string",
                  "minLength": 5,
                  "maxLength": 20
                },
                "account": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9-_]+$"
                },
                "age": {
                  "type": "integer",
                  "min": 0,
                  "max": 100
                },
                "height": {
                  "type": "number",
                  "multipleOf": 42
                },
                "weight": {
                  "type": "number",
                  "exclusiveMinimum": 1
                },
                "awards": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                }
              }
            }
        )",
    },
    {
        "/definitions",
        R"(
            {
              "type": "object",
              "additionalProperties": false,
              "definitions": {
                "TaskId": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9-_]+$"
                },
                "StringOptions": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "string"
                  }
                },
                "FsFileAddr": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "provider",
                    "file_uri"
                  ],
                  "properties": {
                    "provider": {
                      "type": "string",
                      "enum": [
                        "fs"
                      ]
                    },
                    "file_uri": {
                      "type": "string",
                      "minLength": 1
                    }
                  }
                },
                "S3FileAddr": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "provider",
                    "file_uri",
                    "host_uri",
                    "bucket"
                  ],
                  "properties": {
                    "provider": {
                      "type": "string",
                      "enum": [
                        "s3"
                      ]
                    },
                    "file_uri": {
                      "type": "string",
                      "minLength": 1
                    },
                    "s3_region": {
                      "type": "string"
                    },
                    "host_uri": {
                      "type": "string",
                      "minLength": 1
                    },
                    "bucket": {
                      "type": "string",
                      "minLength": 1
                    }
                  }
                },
                "FileAddr": {
                  "anyOf": [
                    {
                      "$ref": "#/definitions/FsFileAddr"
                    },
                    {
                      "$ref": "#/definitions/S3FileAddr"
                    }
                  ]
                }
              }
            }
        )",
    },
    {
        "/encode_task",
        R"(
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "task_id",
                "source",
                "destination",
                "options"
              ],
              "properties": {
                "task_id": {
                  "$ref": "definitions#/definitions/TaskId"
                },
                "source": {
                  "$ref": "definitions#/definitions/FileAddr"
                },
                "destination": {
                  "$ref": "definitions#/definitions/FileAddr"
                },
                "bitrate": {
                  "type": "integer",
                  "min": 0
                },
                "options": {
                  "$ref": "definitions#/definitions/StringOptions"
                }
              }
            }
        )",
    },
    {
        "/transform_task",
        R"(
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "task_id",
                "source",
                "destination"
              ],
              "properties": {
                "task_id": {
                  "$ref": "definitions#/definitions/TaskId"
                },
                "source": {
                  "$ref": "definitions#/definitions/FileAddr"
                },
                "destination": {
                  "$ref": "definitions#/definitions/FileAddr"
                },
                "transform": {
                  "$ref": "#/definitions/Transform"
                }
              },
              "definitions": {
                "Transform": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "angle",
                    "x",
                    "y"
                  ],
                  "properties": {
                    "angle": {
                      "type": "number"
                    },
                    "x": {
                      "type": "number"
                    },
                    "y": {
                      "type": "number"
                    }
                  }
                }
              }
            }
        )",
    },
    {
        "/vehicle",
        R"(
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "type",
                "drivers",
                "props"
              ],
              "properties": {
                "id": {
                  "$ref": "#/definitions/Id"
                },
                "type": {
                  "$ref": "#/definitions/Type"
                },
                "drivers": {
                  "type": "array",
                  "items": {
                    "$ref": "#/definitions/Driver"
                  }
                },
                "props": {
                  "$ref": "#/definitions/Props"
                }
              },
              "definitions": {
                "Id": {
                  "type": "string",
                  "pattern": "^[A-Za-z0-9-_]+$"
                },
                "Type": {
                  "enum": [
                    "bicycle",
                    "car",
                    "truck"
                  ]
                },
                "Driver": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "name",
                    "id"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "min": 5
                    },
                    "id": {
                      "$ref": "#/definitions/Id"
                    }
                  }
                },
                "Props": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "string"
                  }
                }
              }
            }
        )",
    },

};
}
