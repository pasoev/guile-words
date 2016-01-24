;;;; (guile-words) -- a vocabulary library to find the meaning, synonyms,
;;;; antonyms and more for a given word.
;;;;
;;;; Copyright (C) 2016 Sergi Pasoev
;;;;
;;;; This library is free software; you can redistribute it and/or
;;;; modify it under the terms of the GNU Lesser General Public
;;;; License as published by the Free Software Foundation; either
;;;; version 3 of the License, or (at your option) any later version.
;;;;
;;;; This library is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with this library; if not, write to the Free Software
;;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


(define-module (words)
  #:use-module (web client)
  #:use-module (web response)
  #:use-module (json)
  #:use-module (rnrs bytevectors)
  #:use-module (ice-9 format)
  #:use-module (ice-9 pretty-print)
  #:export (meaning
            synonym
            antonym
            usage-examples
            hyphenation
            part-of-speech
            pronunciation
            translate
            bighugelabs))

(define base-urls
  '((#:glosbe . "https://glosbe.com/gapi/translate?from=~a&dest=~a&format=json&pretty=true&phrase=~a")
    (#:wordnik . "http://api.wordnik.com/v4/word.json/~a/~a?api_key=1e940957819058fe3ec7c59d43c09504b400110db7faa0509")
    (#:urbandict . "http://api.urbandictionary.com/v0/~a?term=~a")
    (#:bighugelabs . "http://words.bighugelabs.com/api/2/eb4e57bb2c34032da68dfeb3a0578b68/~a/json")))

(define langs
  '((#:en . "en")))

(define (call-service url)
  (utf8->string (read-response-body (http-get url #:streaming? #t))))

(define* (lookup provider word #:optional (source-lang #:en) (dest-lang #:en) (action "hyphenation"))
  (let* ((base-url (assv-ref base-urls provider))
         (from (assv-ref langs source-lang))
         (to (assv-ref langs dest-lang))
         (url (cond
               ((eq? provider #:wordnik) (format #f base-url word action))
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

(define* (meaning phrase #:optional (source-lang #:en) (dest-lang #:en))
  "
   make calls to the glosbe API

  :param phrase: word for which meaning is to be found
  :param source-lang: Defaults to : ""
  :param dest-lang: Defaults to :"" For eg: "" for french
  :returns: returns a json object as str, False if invalid phrase
  "
  (glosbe phrase source-lang dest-lang))

(define* (synonym phrase #:optional (source-lang #:en) (dest-lang #:en))
  "
   make calls to the glosbe API

  :param phrase: word for which synonyms are to be found
  :param source-lang: Defaults to : ""
  :param dest-lang: Defaults to :"" For eg: "" for french
  :returns: returns a json object as str, False if invalid phrase
  "
  (glosbe phrase source-lang dest-lang))

(define (synonym word)
  (let ((result (json-string->scm (bighugelabs word))))
    (hash-for-each
     (lambda (key value)
       (hash-for-each
        (lambda (k v)
          (when (string=? k "syn")
            (display v)
            (newline)))
        value))
     result)))

(define (antonym word)
  (let ((result (json-string->scm (bighugelabs word))))
    (hash-for-each
     (lambda (key value)
       (hash-for-each
        (lambda (k v)
          (when (string=? k "ant")
            (display v)
            (newline)))
        value))
     result)))

(define (hyphenation word)
  (json-string->scm (wordnik word)))

(antonym "good")
(synonym "good")
(hyphenation "nature")

(define usage-examples 2)
(define hyphenation 3)
(define part-of-speech 4)
(define pronunciation 5)
(define translate 6)


(define* (process action phrase #:optional (source-lang #:en) (dest-lang #:en))
  (action phrase source-lang dest-lang))
