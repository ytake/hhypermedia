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
namespace Ytake\Hhypermedia;

type LinkAttributes = shape(
  ?'type' => string,
  ?'deprecation' => string,
  ?'name' => string,
  ?'profile' => string,
  ?'title' => string,
  ?'hreflang' => string
);

type ErrorAttributes = shape(
  ?'logref' => arraykey,
  ?'path' => string,
);

enum Property: string as string {
  TEMPLATED = 'templated';
  LINKS = '_links';
  EMBEDDED = '_embedded';
  HREF = 'href';
  MESSAGE = 'message';
}
