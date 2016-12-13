from typing import List, Tuple
import sys
import shutil

from  bs4 import BeautifulSoup
from os.path import expanduser, join, isdir
from os import listdir


LINUX_CHROME_EXTENSION_PATH = "~/.config/chromium/Default/Extensions"
OSX_CHROME_EXTENSION_PATH = r"~/Library/Application\ Support/Google/Chrome/Default/Extensions"
EXTENSION_ID = "laookkfknpbbblfpciffpaejjkokdgca"

def get_chrome_extension_path() -> str:
    if sys.platform == "linux" or sys.platform == "linux2":
        return expanduser(LINUX_CHROME_EXTENSION_PATH)
    elif sys.platform == "darwin":
        return expanduser(OSX_CHROME_EXTENSION_PATH)
    elif sys.platform == "win32":
        print("Windows is currently not supported")
        exit(1)
    else:
        print("Unknwon platform not supported.")
        exit(1)


def get_momentum_version(chrome_user_folder: str) -> str:
    versions = listdir(join(chrome_user_folder, EXTENSION_ID))
    if len(versions) > 1:
        # Double check what will happen in this case.
        # Safe handling will probably be take latest lexically sorted version
        pass
    elif len(versions) == 0:
        # This shouldn't happen if we assert momentum is installed above
        pass

    return versions[0]

def get_momentum_path(chrome_user_folder: str, momentum_version: str) -> str:
    return join(chrome_user_folder, EXTENSION_ID, momentum_version)

def show_usage():
    print("Usage: %s <scriptname>" % sys.argv[0])

def get_files(path: str) ->  List[Tuple[str, str]]:
    if not isdir(path):
        return []
    return [(path, filename) for filename in listdir(path)]

class Widget(object):

    def __init__(self, script_source: str):
        self.source = script_source

        # FIXME: if source is git repo, save to temp folder and make path that
        self.path = self.source

        self.css_files = get_files(join(self.path, "css"))
        self.js_files = get_files(join(self.path, "js"))

    def get_name():
        pass

    def get_version():
        pass

    def get_hash():
        pass

class WidgetManager(object):

    def __init__(self, momentum_path: str):
        self.path = momentum_path

        with open(join(momentum_path, "dashboard.html"), mode='r') as file:
            self.soup = BeautifulSoup(file.read(), "html.parser")

        # TODO: init to find out existing scripts, script versions, and parameters

    def add_css_file(self, path, file):
        shutil.copy2(join(path, file), join(self.path, "css", file))
        link_tag = self.soup.new_tag("link")
        link_tag['rel'] = 'stylesheet'
        link_tag['href'] = join('css', file)
        self.soup.link.insert_after(link_tag)

    def add_js_file(self, path, file):
        shutil.copy2(join(path, file), join(self.path, "js", file))
        script_tag = self.soup.new_tag("script")
        script_tag['type'] = 'text/javascript'
        script_tag['src'] = join('js', file)
        self.soup.script.insert_after(script_tag)

    def add_meta_element(self, widget):
        meta_tag = self.soup.new_tag("meta")
        meta_tag['name'] = 'script'
        meta_tag['script-name'] = widget.get_name()
        meta_tag['script-version'] = widget.get_version()
        self.soup.meta.insert_after(meta_tag)

    def install(self, widget: Widget):
        # Install CSS files
        for path, filename in widget.css_files:
            self.add_css_file(path, filename)

        # Install KS files
        for path, filename in widget.js_files:
            self.add_js_file(path, filename)


        # TODO(xLegoz): check if meta tag for this script aready exists
        # do update or install operations depending on it

        self.add_meta_element(widget)

    def save(self):
        # TODO(xLegoz): write to index file back
        pass

    def undo(self):
        # TODO(xLegoz): undo all widget file installs
        pass

if __name__ == "__main__":
    # TODO(xLegoz): Check if momentum is installed
    chrome_extension_path = get_chrome_extension_path()
    momentum_version = get_momentum_version(chrome_extension_path)
    momentum_path = get_momentum_path(chrome_extension_path, momentum_version)

    if len(sys.argv) < 2:
        show_usage()
        exit(1)

    widget_sources = sys.argv[1:]
    widgets = [Widget(widget_source) for widget_source in widget_sources]

    for widget in widgets:
        widget.validate()

    manager = WidgetManager(momentum_path)

# try:
    for widget in widgets:
        manager.install(widget)

    manager.save()
# except: # TODO(xLegoz): Make this widget install only errors
#     manager.undo()
#     # TODO(xLegoz): log error
