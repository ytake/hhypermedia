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
namespace Ytake\Hhypermedia\Serializer;

use type Ytake\Hhypermedia\Property;
use type Ytake\Hhypermedia\RootResource;
use type Ytake\Hhypermedia\Error\MessageResource;
use namespace HH\Lib\Dict;

class VndErrorSerializer extends HalJsonSerializer {

  <<__Override>>
  protected function serialize(
    RootResource $resource,
    dict<arraykey, mixed> $embedded = dict[]
  ): dict<arraykey, mixed> {
    $resource as MessageResource;
    return $this->resolveEmbedded(
      $resource,
      $this->mergeElement(
        $this->resolveLinks($resource),
        Dict\merge(
          $embedded,
          dict[Property::MESSAGE => $resource->getErrorMesage()],
          $resource->getAttributes()
        )
      )
    );
  }
}
