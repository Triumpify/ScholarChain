;; ScholarChain - Learning Token Framework

;; Core Constants
(define-constant admin-addr tx-sender)
(define-constant e401 (err u100))
(define-constant e402 (err u101))
(define-constant e403 (err u102))
(define-constant e404 (err u103))
(define-constant e405 (err u104))
(define-constant e406 (err u105))
(define-constant e407 (err u106))
(define-constant e408 (err u107))
(define-constant e409 (err u108))
(define-constant e410 (err u109))

;; Configuration Variables
(define-data-var u-rate uint u0)
(define-data-var u-fee-bps uint u150)
(define-data-var lock-session bool false)

;; Ledger and Registry
(define-map token-bank principal uint)
(define-map id-registry 
  principal 
  { nm: (string-ascii 55), 
    sid: (string-ascii 22) })
(define-map grant-auth principal bool)

;; View Functions
(define-read-only (bal (acct principal))
  (default-to u0 (map-get? token-bank acct)))

(define-read-only (info (acct principal))
  (map-get? id-registry acct))

(define-read-only (rate)
  (ok (var-get u-rate)))

(define-read-only (is-auth (addr principal))
  (default-to false (map-get? grant-auth addr)))

(define-read-only (lock-status)
  (var-get lock-session))

;; Internal Checks
(define-private (nm-valid? (nm (string-ascii 55)))
  (and (> (len nm) u0) (<= (len nm) u55)))

(define-private (sid-valid? (sid (string-ascii 22)))
  (and (> (len sid) u0) (<= (len sid) u22)))

;; Main Functions
(define-public (reg (nm (string-ascii 55)) (sid (string-ascii 22)))
  (begin
    (asserts! (is-none (info tx-sender)) e408)
    (asserts! (nm-valid? nm) e409)
    (asserts! (sid-valid? sid) e409)
    (ok (map-set id-registry tx-sender {nm: nm, sid: sid}))))

(define-public (mint (amt uint))
  (let ((curr (bal tx-sender)))
    (asserts! (> amt u0) e404)
    (ok (map-set token-bank tx-sender (+ curr amt)))))

(define-public (course-xfer (to principal) (amt uint))
  (let
    (
      (cbal (bal tx-sender))
      (fee (/ (* amt (var-get u-fee-bps)) u10000))
      (deduct (+ amt fee))
      (crate (var-get u-rate))
    )
    (asserts! (not (var-get lock-session)) e410)
    (asserts! (is-some (info tx-sender)) e402)
    (asserts! (is-some (info to)) e402)
    (asserts! (>= cbal deduct) e403)
    (asserts! (> crate u0) e407)
    (try! (stx-transfer? amt tx-sender to))
    (try! (stx-transfer? fee tx-sender admin-addr))
    (map-set token-bank tx-sender (- cbal deduct))
    (ok (/ (* amt crate) u100000000))))

(define-public (redeem (amt uint))
  (let ((balr (bal tx-sender)))
    (asserts! (>= balr amt) e403)
    (try! (as-contract (stx-transfer? amt admin-addr tx-sender)))
    (ok (map-set token-bank tx-sender (- balr amt)))))

(define-public (set-rate (r uint))
  (begin
    (asserts! (is-auth tx-sender) e406)
    (asserts! (> r u0) e407)
    (ok (var-set u-rate r))))

(define-public (lock-toggle (v bool))
  (begin
    (asserts! (is-eq tx-sender admin-addr) e401)
    (ok (var-set lock-session v))))

;; Admin Controls
(define-public (chg-fee (v uint))
  (begin
    (asserts! (is-eq tx-sender admin-addr) e401)
    (asserts! (<= v u10000) e404)
    (ok (var-set u-fee-bps v))))

(define-public (add-auth (a principal))
  (begin
    (asserts! (is-eq tx-sender admin-addr) e401)
    (asserts! (is-none (map-get? grant-auth a)) e409)
    (ok (map-set grant-auth a true))))

(define-public (revoke-auth (a principal))
  (begin
    (asserts! (is-eq tx-sender admin-addr) e401)
    (asserts! (is-some (map-get? grant-auth a)) e409)
    (ok (map-delete grant-auth a))))
