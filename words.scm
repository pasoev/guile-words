(use-modules (web client)
             (web response)
             (json)
             (rnrs bytevectors)
             (ice-9 format)
             (ice-9 pretty-print))

(define base-urls
  '((#:glosbe . "https://glosbe.com/gapi/translate?from=~a&dest=~a&format=json&pretty=true&phrase=~a")
    (#:wordnik . "http://api.wordnik.com/v4/word.json/~a/~a?api_key=1e940957819058fe3ec7c59d43c09504b400110db7faa0509")
    (#:urbandict . "http://api.urbandictionary.com/v0/~a?term=~a")
    (#:bighugelabs . "http://words.bighugelabs.com/api/2/eb4e57bb2c34032da68dfeb3a0578b68/~a/json")))

(define langs
  '((#:en . "en")))

(define (call-service url)
  (utf8->string (read-response-body (http-get url #:streaming? #t))))

(define* (lookup provider word #:optional (source-lang #:en) (dest-lang #:en))
  (let* ((base-url (assv-ref base-urls provider))
         (from (assv-ref langs source-lang))
         (to (assv-ref langs dest-lang))
         (url (cond
               ((eq? provider #:wordnik) (format #f base-url word "definitions"))
               ((eq? provider #:glosbe) (format #f base-url from to word))
               ((eq? provider #:urbandict) (format #f base-url "define" word))
               ((eq? provider #:bighugelabs) (format #f base-url word)))))
    (call-service url)))



(define* (glosbe word #:optional (source-lang #:en) (dest-lang #:en))
  (lookup #:glosbe word source-lang dest-lang))

(define* (wordnik word #:optional (source-lang #:en) (dest-lang #:en))
  (lookup #:wordnik word source-lang dest-lang))

(define (urbandict word)
  (lookup #:urbandict word))

(define (bighugelabs word)
  (lookup #:bighugelabs word))

(display (glosbe "somewhere"))
(newline)
(newline)

(display (wordnik "somewhere"))
(newline)
(newline)
(display (urbandict "somewhere"))
(newline)
(newline)
(display (bighugelabs "somewhere"))
(newline)
(newline)

(display
 (scm->json-string (json (array 1 2 3))))

(define* (meaning phrase #:optional (source-lang #:en) (dest-lang #:en))
  "
   make calls to the glosbe API

  :param phrase: word for which meaning is to be found
  :param source-lang: Defaults to : ""
  :param dest-lang: Defaults to :"" For eg: "" for french
  :returns: returns a json object as str, False if invalid phrase
  "
  (let* ((base-url (assv-ref base-urls #:urbandict))
         (url (format #f base-url phrase )))
    (utf8->string (read-response-body (http-get url #:streaming? #t)))))

(define* (process action phrase #:optional (source-lang #:en) (dest-lang #:en))
  (action phrase source-lang dest-lang))
