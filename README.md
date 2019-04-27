# Hhypermedia
Hypertext Application Language for HHVM/Hack

[![Build Status](https://travis-ci.org/ytake/hhypermedia.svg?branch=master)](https://travis-ci.org/ytake/hhypermedia)

[HAL - Hypertext Application Language](http://stateless.co/hal_specification.html)  
[JSON Hypertext Application Language draft-kelly-json-hal-08](https://tools.ietf.org/html/draft-kelly-json-hal-08)

## Installation

```bash
$ hhvm $(which composer) require ytake/hhhal
```

## Usage

### Basic

```hack
<?hh
use Ytake\HHhal\Serializer\JsonSerializer;
use Ytake\HHhal\{Link, LinkResource, Serializer, HalResource};

$link = new Link('self', new ImmVector([new LinkResource('/users')]));
$resource = new HalResource(new Map([
  'id' => 123456789
]));
$resource->withLink($link);

$hal = new HalResource();
$hal->withEmbedded('tests', $resource);
$serializer = new Serializer(new JsonSerializer(), $hal);
$serializer->serialize();
```

```json
{
  "_embedded":{
    "tests":[
      {
        "id":123456789,
        "_links":{
          "self":{
            "href":"\/tests"
          }
        }
      }
    ]
  }
}
```

### Curies

```hack
use Ytake\HHhal\Serializer\JsonSerializer;
use Ytake\HHhal\{Curie, Link, CurieResource, LinkResource, Serializer, HalResource};

$hal = new HalResource();
$hal->withLink(
  new Link('self', new Vector([new LinkResource('/tests')]))
);
$hal->withLink(
  new Curie(
    new Vector([
      new CurieResource(
        'http://haltalk.herokuapp.com/docs/{rel}', 
        shape('name' => 'heroku')
      )
    ]),
  )
);
$serializer = new Serializer(new JsonSerializer(), $hal);
$serializer->serialize();
```

```json
{
  "_links":{
    "self":{
      "href":"\/tests"
    },
    "curies":[
      {
        "href":"http:\/\/haltalk.herokuapp.com\/docs\/{rel}",
        "templated":true,
        "name":"heroku"
      }
    ]
  }
}
```

### Serialize

Supported Json

## Testing

```bash
$ hhvm ./vendor/bin/hacktest tests/
```
