use type Ytake\Hhypermedia\Serializer\HalJsonSerializer;
use type Ytake\Hhypermedia\Visitor\JsonSerializationVisitor;
use type Ytake\Hhypermedia\{Curie, Link, LinkResource, CurieResource, Serializer, HalResource, ResourceObject};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class SerializerTest extends HackTest {

  public function testShouldBeSerializeString(): void {
    $link = new Link('self', vec[new LinkResource('/tests')]);
    $ro = new ResourceObject();
    $new = $ro->withLink($link);
    $resource = new HalResource($new, dict['id' => 123456789]);

    $secondRo = new ResourceObject()
    |> $$->withEmbedded('tests', vec[$resource]);
    $hal = new HalResource($secondRo);
    $s = new Serializer(
      new HalJsonSerializer(),
      $hal,
      new JsonSerializationVisitor()
    );
    expect($s->toDict())->toBeSame(dict[
      '_embedded' => dict[
        'tests' => vec[
          dict[
            'id' => 123456789,
            '_links' => dict[
              'self' => dict[
                'href' => '/tests'
              ]
            ]
          ]
        ]
      ],
    ]);
  }

  public function testShouldBeSerializeNestedArray(): void {
    $link = new Link('self', vec[new LinkResource('/tests')]);

    $ro = new ResourceObject();
    $new = $ro->withLink($link);
    $new = $new->withLink(new Link(
      'self-two',
      vec[new LinkResource('/tests/test', shape('type' => 'application/vnd.collection+json'))],
    ));
    $resourceNew = new HalResource($new, dict['id' => 123456789]);
    $sampleRo = new ResourceObject();
    $sampleNew = $sampleRo->withEmbedded('sample_embedded', vec[
      new HalResource(new ResourceObject(), dict[
      'id' => 123456789
    ])]);
    $sampleResource = new HalResource($sampleNew, dict['id' => 5678,]);

    $halRo = new ResourceObject();
    $halNew = $halRo->withLink(new Link('self', vec[new LinkResource('/tests/root')]))
    |> $$->withEmbedded('tests', vec[$resourceNew])
    |> $$->withEmbedded('samples', vec[$sampleResource]);
    $hal = new HalResource($halNew, dict['id' => 1234, 'name' => 'ytake']);

    $s = new Serializer(
      new HalJsonSerializer(),
      $hal,
      new JsonSerializationVisitor()
    );
    expect($s->toDict())->toContainKey('_embedded');
    expect($s->toDict())->toBeSame(dict[
      'id' => 1234,
      'name' => 'ytake',
      '_links' => dict[
        'self' => dict[
          'href' => '/tests/root'
        ],
      ],
      '_embedded' => dict[
        'tests' => vec[
          dict[
            'id' => 123456789,
            '_links' => dict[
              'self' => dict[
                'href' => '/tests'
              ],
              'self-two' => dict[
                'href' => '/tests/test',
                'type' => 'application/vnd.collection+json'
              ],
            ]
          ]
        ],
        'samples' => vec[
          dict[
            'id' => 5678,
            '_embedded' => dict[
              'sample_embedded' => vec[
                dict[
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
    $hal = new HalResource(new ResourceObject());
    $s = new Serializer(
      new HalJsonSerializer(),
      $hal,
      new JsonSerializationVisitor()
    );
    expect($s->serialize())->toBeSame('{}');
  }

  public function testShouldBeReturnSerialize(): void {
    $new = new ResourceObject()
    |> $$->withLink(
      new Link('self', vec[new LinkResource('/tests'), new LinkResource('/tests2')])
    );
    $resource = new HalResource($new, dict[
      'id' => 123456789,
      'title' => 9876543210
    ]);
    $rootNew = new ResourceObject()
    |> $$->withEmbedded('tests', vec[
      $resource,
      new HalResource(new ResourceObject(), dict[
        'id' => 1,
        'title' => 'merge emmbedded resource'
      ])
    ]);
    $s = new Serializer(
      new HalJsonSerializer(),
      new HalResource($rootNew),
      new JsonSerializationVisitor()
    );
    $str = '{"_embedded":{"tests":[{"id":123456789,"title":9876543210,"_links":{"self":[{"href":"\/tests"},{"href":"\/tests2"}]}},{"id":1,"title":"merge emmbedded resource"}]}}';
    expect($s->serialize())->toBeSame($str);
  }

  public function testShouldReturnSerializedResourceIncludeCurie(): void {
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
    $str = '{"_links":{"self":{"href":"\/tests"},"curies":[{"href":"http:\/\/haltalk.herokuapp.com\/docs\/{rel}","templated":true,"name":"heroku"}]}}';
    expect($s->serialize())->toBeSame($str);
  }


  public function testShouldReturnEmptyJson2(): void {
    $vec = vec[];
    $vec[] = new ResourceObject()
    |> $$->withLink(new Link('self', vec[new LinkResource('/tests')]))
    |> new HalResource($$, dict[
      'id' => 123456789,
      'title' => 9876543210
    ]);

    $vec[] = new ResourceObject()
    |> $$->withLink(new Link('self', vec[new LinkResource('/tests')]))
    |> new HalResource($$, dict[
      'id' => 123456789,
      'title' => 9876543210
    ]);
    $hal = new ResourceObject()
    |> $$->withEmbedded('samples', $vec)
    |> new HalResource($$);
    $s = new Serializer(
      new HalJsonSerializer(),
      $hal,
      new JsonSerializationVisitor()
    );
    expect($s->serialize())->toBeSame(
      '{"_embedded":{"samples":[{"id":123456789,"title":9876543210,"_links":{"self":{"href":"\/tests"}}},{"id":123456789,"title":9876543210,"_links":{"self":{"href":"\/tests"}}}]}}'
    );
  }
}
