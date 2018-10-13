<?hh // strict

use type Ytake\HHhal\Serializer\JsonSerializer;
use type Ytake\HHhal\{Curie, Link, LinkResource, CurieResource, Serializer, HalResource};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class SerializerTest extends HackTest {

  public function testShouldBeSerializeString(): void {
    $link = new Link(
      'self',
      new Vector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $hal = new HalResource();
    $hal->withEmbedded('tests', Vector{$resource});
    $s = new Serializer(new JsonSerializer(), $hal);
    expect($s->toArray())->toBeSame([
      '_embedded' => [
        'tests' => [
          [
            'id' => 123456789,
            '_links' => [
              'self' => [
                'href' => '/tests'
              ]
            ]
          ]
        ]
      ],
    ]);
  }

  public function testShouldBeSerializeNestedArray(): void {
    $link = new Link(
      'self',
      new Vector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $resource->withLink(new Link(
      'self-two',
      new Vector([new LinkResource('/tests/test', shape('type' => 'application/vnd.collection+json'))]),
    ));
    $hal = new HalResource(new Map([
      'id' => 1234,
      'name' => 'ytake',
    ]));
    $hal->withLink(new Link(
      'self',
      new Vector([new LinkResource('/tests/root')]),
    ));
    $sampleResource = new HalResource(new Map([
      'id' => 5678,
    ]));
    $sampleResource->withEmbedded('sample_embedded', Vector{new HalResource(new Map([
      'id' => 123456789
    ]))});
    $hal->withEmbedded('tests', Vector{$resource});
    $hal->withEmbedded('samples', Vector{$sampleResource});
    $s = new Serializer(new JsonSerializer(), $hal);
    $rawArray = $s->toArray();
    expect($rawArray)->toContainKey('_embedded');
    expect($s->toArray())->toBeSame([
      'id' => 1234,
      'name' => 'ytake',
      '_links' => [
        'self' => [
          'href' => '/tests/root'
        ],
      ],
      '_embedded' => [
        'tests' => [
          [
            'id' => 123456789,
            '_links' => [
              'self' => [
                'href' => '/tests'
              ],
              'self-two' => [
                'href' => '/tests/test',
                'type' => 'application/vnd.collection+json'
              ],
            ]
          ]
        ],
        'samples' => [
          [
            'id' => 5678,
            '_embedded' => [
              'sample_embedded' => [
                [
                  'id' => 123456789,
                ]
              ]
            ],
          ]
        ]
      ],
    ]);
    $str = '{"id":1234,"name":"ytake","_links":{"self":{"href":"\/tests\/root"}},"_embedded":{"tests":[{"id":123456789,"_links":{"self":{"href":"\/tests"},"self-two":{"href":"\/tests\/test","type":"application\/vnd.collection+json"}}}],"samples":[{"id":5678,"_embedded":{"sample_embedded":[{"id":123456789}]}}]}}';
    expect($s->serialize())->toBeSame($str);
  }

  public function testShouldReturnEmptyJson(): void {
    $hal = new HalResource();
    $s = new Serializer(new JsonSerializer(), $hal);
    expect($s->serialize())->toBeSame('{}');
  }

  public function testShouldBeReturnSerialize(): void {
    $root = new HalResource();
    $link = new Link('self',
      new Vector([
        new LinkResource('/tests'),
        new LinkResource('/tests2')
      ]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789,
      'title' => 9876543210
    ]));
    $resource->withLink($link);
    $root->withEmbedded('tests', Vector{
      $resource,
      new HalResource(new Map([
        'id' => 1,
        'title' => 'merge emmbedded resource'
      ]))
    });
    $s = new Serializer(new JsonSerializer(), $root);
    $str = '{"_embedded":{"tests":[{"id":123456789,"title":9876543210,"_links":{"self":[{"href":"\/tests"},{"href":"\/tests2"}]}},{"id":1,"title":"merge emmbedded resource"}]}}';
    expect($s->serialize())->toBeSame($str);
  }

  public function testShouldReturnSerializedResourceIncludeCurie(): void {
    $root = new HalResource();
    $link = new Link('self',
      new Vector([
        new LinkResource('/tests')
      ]),
    );
    $root->withLink($link);
    $root->withLink(new Curie(
      new Vector([
        new CurieResource(
          'http://haltalk.herokuapp.com/docs/{rel}',
          shape('name' => 'heroku')
        )
      ]),
    ));
    $s = new Serializer(new JsonSerializer(), $root);
    $str = '{"_links":{"self":{"href":"\/tests"},"curies":[{"href":"http:\/\/haltalk.herokuapp.com\/docs\/{rel}","templated":true,"name":"heroku"}]}}';
    expect($s->serialize())->toBeSame($str);
  }

  public function testShouldReturnEmptyJson2(): void {
    $hal = new HalResource();
    $vec = Vector{ };
    $resource = new HalResource(new Map([
      'id' => 123456789,
      'title' => 9876543210
    ]));
    $resource->withLink(new Link('self',
      new Vector([
        new LinkResource('/tests')
      ]),
    ));
    $vec->add($resource);
    $resource = new HalResource(new Map([
      'id' => 123456789,
      'title' => 9876543210
    ]));
    $resource->withLink(new Link('self',
      new Vector([
        new LinkResource('/tests')
      ]),
    ));
    $vec->add($resource);
    $hal->withEmbedded('samples', $vec);
    $s = new Serializer(new JsonSerializer(), $hal);
    expect($s->serialize())->toBeSame(
      '{"_embedded":{"samples":[{"id":123456789,"title":9876543210,"_links":{"self":{"href":"\/tests"}}},{"id":123456789,"title":9876543210,"_links":{"self":{"href":"\/tests"}}}]}}'
    );
  }
}
