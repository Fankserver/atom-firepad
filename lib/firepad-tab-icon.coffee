cssElements = {}

module.exports =
class TabIcon

  getCssElement: (path) ->
    cssElement = cssElements[path]
    unless cssElement?
      cssElement = document.createElement 'style'
      cssElement.setAttribute 'type', 'text/css'
      cssElements[path] = cssElement
    while cssElement.firstChild?
      cssElement.removeChild cssElement.firstChild
    path = path.replace(/\\/g,"\\\\")
    css =
    "
      ul.tab-bar > li.tab[data-path='#{path}'][is='tabs-tab'] > div.title::before   {
        color: orange;
        content: '\\f037';
      }
    "
    cssElement.appendChild document.createTextNode css
    return cssElement


  processPath: (path,revert=false) ->
    cssElement = @getCssElement path
    unless revert
      tabDivs = atom.views.getView(atom.workspace).querySelectorAll "ul.tab-bar>
        li.tab[data-type='TextEditor']>
        div.title[data-path='#{path.replace(/\\/g,"\\\\")}']"
      for tabDiv in tabDivs
        tabDiv.parentElement.setAttribute "data-path", path
      unless cssElement.parentElement?
        head = document.getElementsByTagName('head')[0]
        head.appendChild cssElement
    else
      if cssElement.parentElement?
        cssElement.parentElement.removeChild(cssElement)
