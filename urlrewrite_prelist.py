import re
import urllib
import logging
from plugin_urlrewriting import UrlRewritingError
from flexget.entry import Entry
from flexget.plugin import register_plugin, internet, PluginWarning
from flexget.utils import requests
from flexget.utils.soup import get_soup
from flexget.utils.search import torrent_availability, StringComparator
from flexget import validator

log = logging.getLogger('prelist')

class UrlRewritePrelist(object):
    """Prelist urlrewriter."""

    def validator(self):
        root = validator.factory()
        root.accept('boolean')
        advanced = root.accept('dict')
        return root

    # urlrewriter API
    def url_rewritable(self, task, entry):
        url = entry['url']
        if url.startswith('http://www.prelist.ws/'):
            return True
        return False

    # urlrewriter API
    def url_rewrite(self, task, entry):
        if not 'url' in entry:
            log.error("Didn't actually get a URL...")
        else:
            log.debug("Got the URL: %s" % entry['url'])
        if entry['url'].startswith('http://www.prelist.ws/'):
            # use search
            try:
                entry['url'] = self.search(entry['title'])[0]['url']
            except PluginWarning, e:
                raise UrlRewritingError(e)
        else:
            # parse download page
            entry['url'] = self.parse_download_page(entry['url'])

    @internet(log)
    def parse_download_page(self, url):
        page = requests.get(url).content
        try:
            soup = get_soup(page)
            tag_div = soup.find('div', attrs={'class': 'download'})
            if not tag_div:
                raise UrlRewritingError('Unable to locate download link from url %s' % url)
            tag_a = tag_div.find('a')
            torrent_url = tag_a.get('href')
            # URL is sometimes missing the schema
            if torrent_url.startswith('//'):
                torrent_url = 'http:' + torrent_url
            return torrent_url
        except Exception, e:
            raise UrlRewritingError(e)

    @internet(log)
    def search(self, query, comparator=StringComparator(), config=None):
        """
        Search for name from prelist.
        """
        if not isinstance(config, dict):
            config = {}
       

        comparator.set_seq1(query)
        query = comparator.search_string()
        # urllib.quote will crash if the unicode string has non ascii characters, so encode in utf-8 beforehand
        url = 'http://www.prelist.ws/?search=' + urllib.quote(query.encode('utf-8')) 
        log.debug('Using %s as prelist search url' % url)
        page = requests.get(url).content
        soup = get_soup(page)
        entries = []
        for link in soup.find_all('a',attrs={'href' : re.compile('search=')}):
            log.debug('name: %s' % link)

            comparator.set_seq2(link.contents[0])
            log.debug('name: %s' % comparator.a)
            log.debug('found name: %s' % comparator.b)
            log.debug('confidence: %s' % comparator.ratio())
            if not comparator.matches():
                continue
            entry = Entry()
            entry['title'] = link.contents[0]
            entry['url'] = 'http://www.prelist.ws/' + link.get('href')
            entries.append(entry)


        return entries

register_plugin(UrlRewritePrelist, 'prelist', groups=[ 'search'])
