-- Calcolo delle sessioni per fase
WITH user_journey AS (
  SELECT
    user_id,
    SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS add_to_cart,
    SUM(CASE WHEN event_type = 'checkout' THEN 1 ELSE 0 END) AS checkout
  FROM ecommerce_events
  GROUP BY user_id
),

-- Classificazione degli utenti in base al completamento
prodotto_stages AS (
  SELECT
    user_id,
    CASE 
      WHEN checkout >= 1 THEN 'Completato acquisto'
      WHEN add_to_cart >= 1 THEN 'Abbandonato al checkout'
      WHEN page_views >= 1 THEN 'Abbandonato al carrello'
      ELSE 'Solo visita'
    END AS prodotto_stage
  FROM user_journey
)

--  Analisi aggregata per identificare prodotto
SELECT
  prodotto_stage,
  COUNT(user_id) AS users,
  ROUND((COUNT(user_id) / LAG(COUNT(user_id)) OVER (ORDER BY CASE prodotto_stage 
    WHEN 'Completato acquisto' THEN 3
    WHEN 'Abbandonato al checkout' THEN 2
    WHEN 'Abbandonato al carrello' THEN 1
    ELSE 0
  END) * 100, 2) AS conversion_rate
FROM prodotto_stages
GROUP BY prodotto_stage
ORDER BY CASE prodotto_stage 
  WHEN 'Completato acquisto' THEN 3
  WHEN 'Abbandonato al checkout' THEN 2
  WHEN 'Abbandonato al carrello' THEN 1
  ELSE 0
END DESC;
