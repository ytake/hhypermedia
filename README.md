# hhhal
Hypertext Application Language for HHVM/Hack

[![Build Status](https://travis-ci.org/ytake/hhhal.svg?branch=master)](https://travis-ci.org/ytake/hhhal)

## Installation

```bash
$ hhvm -d xdebug.enable=0 -d hhvm.jit=0 -d hhvm.php7.all=1\
 -d hhvm.hack.lang.auto_typecheck=0 $(which composer) require ytake/hhhal
```

## Usage

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
new Serializer(new JsonSerializer(), $hal);
```

## Testing

```bash
$ hhvm -d xdebug.enable=0 -d hhvm.jit=0 -d hhvm.php7.all=1\
 -d hhvm.hack.lang.auto_typecheck=0 ./vendor/bin/phpunit
```
