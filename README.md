# Hhypermedia

Hypertext Application Language for HHVM/Hack

![Travis (.org) branch(https://travis-ci.org/ytake/hhypermedia.svg?branch=master)](https://img.shields.io/travis/ytake/hhypermedia/master.svg?style=flat-square)
[![Packagist](https://img.shields.io/packagist/dt/ytake/hhypermedia.svg?style=flat-square)](https://packagist.org/packages/ytake/hhypermedia)
[![Packagist Version](https://img.shields.io/packagist/v/ytake/hhypermedia.svg?color=orange&style=flat-square)](https://packagist.org/packages/ytake/hhypermedia)
[![Packagist](https://img.shields.io/packagist/l/ytake/hhypermedia.svg?style=flat-square)](https://packagist.org/packages/ytake/hhypermedia)

## Supported

[HAL - Hypertext Application Language](http://stateless.co/hal_specification.html)  
[JSON Hypertext Application Language draft-kelly-json-hal-08](https://tools.ietf.org/html/draft-kelly-json-hal-08)  
[vnd.error](https://github.com/blongden/vnd.error)

## Requirements

HHVM 4.0.0 and above.

1. [Installation](#1-installation)
2. [Usage](#2-usage)
3. [vnd.error](#3-vnd-error)

## 1.Installation

```bash
$ composer require ytake/hhypermedia
```

## 2.Usage

Given a Hack Object,
the hal+json transformer will represent the given data following the [`JSON Hypertext Application Language draft-kelly-json-hal-08`](https://tools.ietf.org/html/draft-kelly-json-hal-08) specification draft.

### Basic

```hack
use type Ytake\Hhypermedia\Serializer\HalJsonSerializer;
use type Ytake\Hhypermedia\Link;
use type Ytake\Hhypermedia\LinkResource;
use type Ytake\Hhypermedia\Serializer;
use type Ytake\Hhypermedia\HalResource;
use type Ytake\Hhypermedia\ResourceObject;
use type Ytake\Hhypermedia\Visitor\JsonSerializationVisitor;

$link = new Link('self', vec[new LinkResource('/users')]);
$ro = new ResourceObject()
|> $$->withLink($link);
$resource = new HalResource($ro, dict['id' => 123456789]);

$secondRo = new ResourceObject()
|> $$->withEmbedded('tests', vec[$resource]);
$hal = new HalResource($secondRo);
$s = new Serializer(
  new HalJsonSerializer(),
  $hal,
  new JsonSerializationVisitor()
);
echo $s->serialize();
```

#### Basic - Result

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
use type Ytake\Hhypermedia\Link;
use type Ytake\Hhypermedia\Curie;
use type Ytake\Hhypermedia\CurieResource;
use type Ytake\Hhypermedia\LinkResource;
use type Ytake\Hhypermedia\Serializer;
use type Ytake\Hhypermedia\HalResource;
use type Ytake\Hhypermedia\ResourceObject;
use type Ytake\Hhypermedia\Serializer\HalJsonSerializer;
use type Ytake\Hhypermedia\Visitor\JsonSerializationVisitor;

$ro = new ResourceObject()
|> $$->withLink(new Link('self', vec[new LinkResource('/tests')]))
|> $$->withLink(new Curie(vec[
  new CurieResource('http://haltalk.herokuapp.com/docs/{rel}', shape('name' => 'heroku'))
]));
$s = new Serializer(
  new HalJsonSerializer(),
  new HalResource($ro),
  new JsonSerializationVisitor()
);
echo $s->serialize();
```

#### Curies - Result

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

## 3.vnd.error

Supported the [vnd.error](https://github.com/blongden/vnd.error).

```hack
use type Ytake\Hhypermedia\Serializer;
use type Ytake\Hhypermedia\LinkResource;
use type Ytake\Hhypermedia\Error\ErrorLink;
use type Ytake\Hhypermedia\Error\MessageResource;
use type Ytake\Hhypermedia\ResourceObject;
use type Ytake\Hhypermedia\Serializer\VndErrorSerializer;
use type Ytake\Hhypermedia\Visitor\JsonSerializationVisitor;

$linkVec = vec[new LinkResource('http://...')];
$new = new ResourceObject()
|> $$->withLink( new ErrorLink('help', $linkVec))
|> $$->withLink( new ErrorLink('about', $linkVec))
|> $$->withLink( new ErrorLink('describes', $linkVec));

$s = new Serializer(
  new VndErrorSerializer(),
  new MessageResource(
    'Validation failed',
    $new,
    shape('logref' => 42, 'path' => '/username')
  ),
  new JsonSerializationVisitor()
);
\var_dump($s->toDict());
```

### vnd.error - toDict

```hack
dict[
  'message' => 'Validation failed',
  'logref' => 42,
  'path' => '/username',
  '_links' => dict[
    'help' => dict[
      'href' => 'http://...'
    ],
    'about' => dict[
      'href' => 'http://...'
    ],
    'describes' => dict[
      'href' => 'http://...'
    ],
  ]
]
```

### vnd.error - Result

```json
{
  "message": "Validation failed",
  "path": "/username",
  "logref": 42,
  "_links": {
    "about": {
      "href": "http://..."
    },
    "describes": {
      "href": "http://..."
    },
    "help": {
      "href": "http://..."
    }
  }
}
```
