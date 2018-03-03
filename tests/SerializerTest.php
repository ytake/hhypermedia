<?hh // strict

use Ytake\HHhal\Serializer\JsonSerializer;
use Ytake\HHhal\{Link, LinkResource, Serializer, HalResource};
use PHPUnit\Framework\TestCase;

class SerializerTestTest extends TestCase {

  public function testShouldBeSerializeString(): void {
    $link = new Link(
      'self',
      new ImmVector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $hal = new HalResource();
    $hal->withEmbedded('tests', $resource);
    $s = new Serializer(new JsonSerializer(), $hal);
    $this->assertSame([
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
    ], $s->rawArray());
  }

  public function testShouldBeSerializeNestedArray(): void {
    $link = new Link(
      'self',
      new ImmVector([new LinkResource('/tests')]),
    );
    $resource = new HalResource(new Map([
      'id' => 123456789
    ]));
    $resource->withLink($link);
    $resource->withLink(new Link(
      'self-two',
      new ImmVector([new LinkResource('/tests/test')]),
    ));
    $hal = new HalResource(new Map([
      'id' => 1234,
      'name' => 'ytake',
    ]));
    $hal->withLink(new Link(
      'self',
      new ImmVector([new LinkResource('/tests/root')]),
    ));
    $sampleResource = new HalResource(new Map([
      'id' => 5678,
    ]));
    $sampleResource->withEmbedded('sample_embedded', new HalResource(new Map([
      'id' => 123456789
    ])));
    $hal->withEmbedded('tests', $resource);
    $hal->withEmbedded('samples', $sampleResource);
    $s = new Serializer(new JsonSerializer(), $hal);
    $rawArray = $s->rawArray();
    $this->assertArrayHasKey('_embedded', $rawArray);
    $this->assertSame([
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
                'href' => '/tests/test'
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
    ], $s->rawArray());
    $str = '{"id":1234,"name":"ytake","_links":{"self":{"href":"\/tests\/root"}},"_embedded":{"tests":[{"id":123456789,"_links":{"self":{"href":"\/tests"},"self-two":{"href":"\/tests\/test"}}}],"samples":[{"id":5678,"_embedded":{"sample_embedded":[{"id":123456789}]}}]}}';
    $this->assertSame($str, $s->serialize());
  }
}
