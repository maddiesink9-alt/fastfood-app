;; fastfood-app
;; Clarity contract for a decentralized food delivery platform

(define-data-var order-counter uint u0)

(define-map orders
    { id: uint }
    {
        customer: principal,
        restaurant: (string-ascii 50),
        driver: (optional principal),
        status: (string-ascii 10),
    }
)

;; Place a food order
(define-public (place-order (restaurant (string-ascii 50)))
    (begin
        (asserts! (> (len restaurant) u0) (err u1))
        (let ((id (var-get order-counter)))
            (map-set orders { id: id } {
                customer: tx-sender,
                restaurant: restaurant,
                driver: none,
                status: "open",
            })
            (var-set order-counter (+ id u1))
            (ok id)
        )
    )
)

;; Accept an order as a driver
(define-public (accept-order (id uint))
    (match (map-get? orders { id: id })
        order
        (if (is-eq (get status order) "open")
            (begin
                (map-set orders { id: id } {
                    customer: (get customer order),
                    restaurant: (get restaurant order),
                    driver: (some tx-sender),
                    status: "accepted",
                })
                (ok "Order accepted")
            )
            (err u2)
        )
        ;; not open
        (err u3)
    )
    ;; order not found
)

;; Mark order as delivered
(define-public (mark-delivered (id uint))
    (match (map-get? orders { id: id })
        order
        (if (and (is-eq (get status order) "accepted") (is-eq tx-sender (unwrap! (get driver order) (err u4))))
            (begin
                (map-set orders { id: id } {
                    customer: (get customer order),
                    restaurant: (get restaurant order),
                    driver: (get driver order),
                    status: "delivered",
                })
                (ok "Order delivered")
            )
            (err u5)
        )
        ;; not accepted or not driver
        (err u6)
    )
    ;; order not found
)