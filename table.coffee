Table =

  numberRegExp: /^-?[£$¤]?[\d,.]+%?$/

  makeSortable: (table) ->
    return if table.tHead.rows.length isnt 1

    ths = table.querySelectorAll('th')

    for th, i in ths
      if th.getAttribute('data-sort') isnt 'false'
        Table.setupClickableTH table, th, i

    table

  setupClickableTH: (table, th, i) ->
    sortFunction = Table.getSortFunctionFromColumnIndex table, i

    th.addEventListener 'click', (e) ->
      tBody = table.tBodies[0]

      if @getAttribute('data-sorted') is 'true'
        Table.reverse table
        @setAttribute 'data-sorted-reverse', if @getAttribute('data-sorted-reverse') isnt 'true' then 'true' else 'false'
        return

      ths = @parentNode.querySelectorAll('th')
      for th in ths
        th.setAttribute 'data-sorted', 'false'
        th.setAttribute 'data-sorted-reverse', 'false'

      @setAttribute 'data-sorted', 'true'

      rowArray = []

      r = 0
      while r < tBody.rows.length
        rowArray[rowArray.length] = [Table.getNodeValue(tBody.rows[r].cells[i]), tBody.rows[r]]
        r++

      rowArray.sort sortFunction

      fragment = document.createDocumentFragment()

      r = 0
      while r < rowArray.length
        fragment.appendChild rowArray[r][1].cloneNode(true)
        r++

      tBody.innerHTML = ''
      tBody.appendChild fragment

  getSortFunctionFromColumnIndex: (table, i) ->
    sortFn = Table.sortAlpha
    r = 0
    while r < table.tBodies[0].rows.length
      text = Table.getNodeValue table.tBodies[0].rows[r].cells[i]
      return Table.sortNumeric if text isnt '' and text.match(Table.numberRegExp)
      r++
    sortFn

  getNodeValue: (node) ->
    return '' unless node
    return node.getAttribute('data-value') if node.getAttribute('data-value') isnt null
    return node.innerText.replace(/^\s+|\s+$/g, '') unless typeof node.innerText is 'undefined'
    node.textContent.replace /^\s+|\s+$/g, ''

  reverse: (table) ->
    tBody = table.tBodies[0]
    fragment = document.createDocumentFragment()

    r = tBody.rows.length - 1
    while r >= 0
      fragment.appendChild tBody.rows[r].cloneNode(true)
      r--

    tBody.innerHTML = ''
    tBody.appendChild fragment

  sortNumeric: (a, b) ->
    aa = parseFloat(a[0].replace(/[^0-9.-]/g, ''))
    bb = parseFloat(b[0].replace(/[^0-9.-]/g, ''))
    aa = 0 if isNaN(aa)
    bb = 0 if isNaN(bb)
    aa - bb

  sortAlpha: (a, b) ->
    aa = a[0].toLowerCase()
    bb = b[0].toLowerCase()
    return 0 if aa is bb
    return -1 if aa < bb
    1

window.Table = Table