# Hhypermedia

Hypertext Application Language for HHVM/Hack

[![Build Status](https://travis-ci.org/ytake/hhypermedia.svg?branch=master)](https://travis-ci.org/ytake/hhypermedia)

[HAL - Hypertext Application Language](http://stateless.co/hal_specification.html)  
[JSON Hypertext Application Language draft-kelly-json-hal-08](https://tools.ietf.org/html/draft-kelly-json-hal-08)

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
use Ytake\Hhypermedia\Serializer\HalJsonSerializer;
use Ytake\Hhypermedia\Link;
use Ytake\Hhypermedia\LinkResource;
use Ytake\Hhypermedia\Serializer;
use Ytake\Hhypermedia\HalResource;
use Ytake\Hhypermedia\ResourceObject;

$link = new Link('self', vec[new LinkResource('/users')]);
$ro = new ResourceObject()
|> $$->withLink($link);
$resource = new HalResource($ro, dict['id' => 123456789]);

$secondRo = new ResourceObject();
|> $$->withEmbedded('tests', vec[$resource]);
$hal = new HalResource($secondRo);
$s = new Serializer(new HalJsonSerializer(), $hal);
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
use Ytake\Hhypermedia\Link;
use Ytake\Hhypermedia\Curie;
use Ytake\Hhypermedia\CurieResource;
use Ytake\Hhypermedia\LinkResource;
use Ytake\Hhypermedia\Serializer;
use Ytake\Hhypermedia\HalResource;
use Ytake\Hhypermedia\ResourceObject;
use Ytake\Hhypermedia\Serializer\HalJsonSerializer;

$ro = new ResourceObject()
|> $$->withLink(new Link('self', vec[new LinkResource('/tests')]))
|> $$->withLink(new Curie(vec[
  new CurieResource('http://haltalk.herokuapp.com/docs/{rel}', shape('name' => 'heroku'))
]));
$s = new Serializer(new HalJsonSerializer(), new HalResource($ro));
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
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink( new ErrorLink('help', $linkVec))
    |> $$->withLink( new ErrorLink('about', $linkVec))
    |> $$->withLink( new ErrorLink('describes', $linkVec));
    $attributes = shape('logref' => 42, 'path' => '/username');
    $message = new MessageResource('Validation failed', $new, $attributes);
    $s = new Serializer(new VndErrorSerializer(), $message);
```