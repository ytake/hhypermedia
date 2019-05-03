use type Ytake\Hhypermedia\Serializer;
use type Ytake\Hhypermedia\LinkResource;
use type Ytake\Hhypermedia\Error\ErrorLink;
use type Ytake\Hhypermedia\Error\MessageResource;
use type Ytake\Hhypermedia\ResourceObject;
use type Ytake\Hhypermedia\Serializer\VndErrorSerializer;
use type Ytake\Hhypermedia\Visitor\JsonSerializationVisitor;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class VndErrorSerializerTest extends HackTest {

  public function testShouldBeSerializeDict(): void {
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink( new ErrorLink('help', $linkVec))
    |> $$->withLink( new ErrorLink('about', $linkVec))
    |> $$->withLink( new ErrorLink('describes', $linkVec));
    $attributes = shape('logref' => 42, 'path' => '/username');
    $message = new MessageResource('Validation failed', $new, $attributes);
    $s = new Serializer(
      new VndErrorSerializer(),
      $message,
      new JsonSerializationVisitor()
    );
    expect($s->toDict())->toBeSame(dict[
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
    ]);
  }

  public function testShouldBeSerializeString(): void {
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink( new ErrorLink('help', $linkVec))
    |> $$->withLink( new ErrorLink('about', $linkVec))
    |> $$->withLink( new ErrorLink('describes', $linkVec));
    $attributes = shape('logref' => 42, 'path' => '/username');
    $message = new MessageResource('Validation failed', $new, $attributes);
    $s = new Serializer(
      new VndErrorSerializer(),
      $message,
      new JsonSerializationVisitor()
    );
    $str = '{"message":"Validation failed","logref":42,"path":"\/username","_links":{"help":{"href":"http:\/\/..."},"about":{"href":"http:\/\/..."},"describes":{"href":"http:\/\/..."}}}';
    expect($s->serialize())->toBeSame($str);
  }

  public function testShouldSerializeNEstedErrors(): void {
    $embedNew = new ResourceObject()
    |> $$->withLink(new ErrorLink('about', vec[
      new LinkResource('http://path.to/user/resource/1')
    ]));
    $message = new MessageResource(
      'Username must contain at least three characters',
      $embedNew,
      shape('path' => '/username')
    );
    $linkVec = vec[new LinkResource('http://...', shape())];
    $new = new ResourceObject()
    |> $$->withLink(new ErrorLink('help', $linkVec))
    |> $$->withLink(new ErrorLink('describes', $linkVec))
    |> $$->withLink(new ErrorLink('about', $linkVec))
    |> $$->withEmbedded('errors', vec[$message]);
    $attributes = shape('logref' => 42);
    $message = new MessageResource('Validation failed', $new, $attributes);
    $s = new Serializer(
      new VndErrorSerializer(),
      $message,
      new JsonSerializationVisitor()
    );
    expect($s->toDict())->toBeSame(dict[
      'message' => 'Validation failed',
      'logref' => 42,
      '_links' => dict[
        'help' => dict[
          'href' => 'http://...'
        ],
        'describes' => dict[
          'href' => 'http://...'
        ],
        'about' => dict[
          'href' => 'http://...'
        ],
      ],
      '_embedded' => dict[
        'errors' => vec[
          dict[
            'message' => 'Username must contain at least three characters',
            'path' => '/username',
            '_links' => dict[
              'about' => dict[
                'href' => 'http://path.to/user/resource/1'
              ]
            ]
          ],
        ]
      ]
    ]);
  }
}
