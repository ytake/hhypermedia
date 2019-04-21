/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2018-2019 Yuuki Takezawa
 *
 */
namespace Ytake\HHhal;

class HalResource implements RootResource {

  public function __construct(
    private ResourceObject<this> $resourceObject,
    protected dict<arraykey, mixed> $resources = dict[]
  ) {}

  public function addResource(
    arraykey $key, mixed $value
  ): this {
    $this->resources[$key] = $value;
    return $this;
  }

  public function getLinks(): dict<string, Link> {
    return $this->resourceObject->getLinks();
  }

  public function getEmbedded(): dict<string, vec<this>> {
    return $this->resourceObject->getEmbedded();
  }

  public function getResource(): dict<arraykey, mixed> {
    return $this->resources;
  }
}
