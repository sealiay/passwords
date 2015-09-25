
angular
  .module "passwords", ["ui.bootstrap", "ngClipboard"]

  .factory "aes", () ->
    window.aes =
      key: (k) ->
        @k = k if k?
        @k

      encrypt: (m) ->
        CryptoJS.AES
          .encrypt m, @k
          .toString()

      decrypt: (e) ->
        CryptoJS.AES
          .decrypt e, @k
          .toString CryptoJS.enc.Utf8

  .factory "empty", () ->
    (o) ->
      return on if not o? or o.length is 0
      return no if o.length? and o.length > 0
      for k of o
        return no if o.hasOwnProperty k
      on

  .factory "pwd", () ->
    (p) ->
      if p? and p.length? and p.trim().length > 2
        p.trim()
      else
        l = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm" +
        "012345678901234567890123456789012345678901234567890123456789"
        n = Number p or 10
        p = (l[Math.floor(Math.random() * l.length)] for i in [1..n])
        "_" + p.join("")

  .factory "mgr", ($http, aes, empty)->
    window.mgr =
      str: (s) ->
        if s?
          @s = s
          @o = (try JSON.parse aes.decrypt s) ? {}
        @s

      obj: (o) ->
        if o?
          @o = o
          @s = (try aes.encrypt JSON.stringify o) ? ""
        @o

      add: (web, usr, pwd) ->
        @o[web] ?= {}
        @o[web][usr] = pwd
        @rat()

      del: (web, usr) ->
        delete @o[web][usr]
        delete @o[web] if empty @o[web]
        @rat()

      get: ->
        $http
          .get "gg.txt"
          .success (d) => @str d

      rat: -> @obj @o

  .controller "controller", ($scope, aes, mgr, pwd) ->
    $scope.key = (a...) -> aes.key a...
    $scope.str = (a...) -> mgr.str a...
    $scope.obj = (a...) -> mgr.obj a...
    $scope.del = (a...) -> mgr.del a...
    $scope.get = (a...) -> mgr.get a...
    $scope.rat = (a...) -> mgr.rat a...

    $scope.add = (w, u, p) -> mgr.add w, u, pwd p

    $scope.sav = -> localStorage.setItem "aes-key", aes.key()

    $scope.opt =
      getterSetter: true
      debounce: "default": 500, blur: 0

    k = localStorage.getItem "aes-key"
    if aes.key k or "" then mgr.get() else mgr.obj {}

angular.bootstrap document, ["passwords"]

###
gg =
  "xxx.com":
    a: 11
    b: 22
  "yyy.com":
    a: 12
    b: 23
###
