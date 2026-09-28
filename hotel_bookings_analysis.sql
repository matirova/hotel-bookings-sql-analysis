SELECT *
FROM hotel_bookings;

SELECT hotel,
       COUNT(*)as Total_Reservas,
       SUM(CASE WHEN is_canceled=1 THEN 1 ELSE 0 END)as Total_cancelaciones,
       ROUND(
           SUM(CASE WHEN is_canceled=1 THEN 1 ELSE 0 END)*100/COUNT(*),2
            )as tasa_cancelacion_pct
FROM hotel_bookings
GROUP  BY hotel;

---VOLUMEN DE RESERVAS POR EN CADA MES POR HOTEL DE MAYOR A MENOR---
SELECT   hotel,
         arrival_date_month,
         COUNT(*) as Total_Reservas,
         ROUND(AVG(adr),2) as adr_promedio
FROM hotel_bookings
WHERE is_canceled=0
GROUP BY hotel,arrival_date_month
ORDER BY hotel ,COUNT(*)DESC;
---TOP 10 SEMANAS CON MAS RESERVAS POR HOTEL---
WITH Ranking_Semanal as(
SELECT hotel,
       arrival_date_week_number,
       COUNT(*)as total_reservas,
       ROUND(AVG(adr), 2) AS adr_promedio,
       ROW_NUMBER() OVER(PARTITION BY hotel ORDER BY  COUNT(*)) as RANKING
FROM hotel_bookings
WHERE is_canceled=0
GROUP BY hotel,arrival_date_week_number
)
SELECT hotel,
       arrival_date_week_number,
       total_reservas,
       adr_promedio
FROM Ranking_Semanal 
WHERE ranking <= 10
ORDER BY hotel,RANKING



----Análisis de Duración de Estancia y Patrones de Viaje---
SELECT hotel,
       ROUND(AVG(CAST(stays_in_weekend_nights AS FLOAT)), 2) AS promedio_noches_fin_de_semana,
       ROUND(AVG(CAST(stays_in_week_nights AS FLOAT)), 2) AS promedio_noches_entre_semana,
       ROUND(AVG(CAST(stays_in_weekend_nights + stays_in_week_nights AS FLOAT)), 2) AS promedio_duracion_estancia,
       CASE 
           WHEN AVG(CAST(stays_in_weekend_nights AS FLOAT)) > AVG(CAST(stays_in_week_nights AS FLOAT)) THEN 'Enfoque de Fin de Semana'
           WHEN AVG(CAST(stays_in_weekend_nights AS FLOAT)) > (AVG(CAST(stays_in_week_nights AS FLOAT)) * 2) THEN 'Estancia Larga / Negocios'
           ELSE 'Estancia Mixta / Vacacional'
       END AS Patron_estancia
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel;


----Determinar la mejor época para reservar---
SELECT hotel,
       arrival_date_month as mes_de_llegada,
       CASE WHEN lead_time=0 THEN '0.Mismo dia'
            WHEN lead_time>=1 and lead_time<=7 THEN '1.Sobre la hora (1-7 DIAS)'
            WHEN lead_time>=8 and lead_time<=30 THEN '2.Corto plazo (8-30 DIAS)'
            WHEN lead_time>=31 and lead_time<=90THEN '3.Mediano plazo (1-3 MESES)'
            WHEN lead_time>=91 and lead_time<=180THEN '4.Largo plazo (3-6 MESES)'
            ELSE '5. Muy a largo plazo (> 6 meses)'
            END AS rango_anticipacion,
       ROUND(AVG(adr),2)as promedio_adr,
       COUNT(*)AS Total_ordenes
FROM hotel_bookings
WHERE is_canceled=0 AND adr > 0 AND adr < 1000
GROUP BY hotel,arrival_date_month,
         CASE WHEN lead_time=0 THEN '0.Mismo dia'
            WHEN lead_time>=1 and lead_time<=7 THEN '1.Sobre la hora (1-7 DIAS)'
            WHEN lead_time>=8 and lead_time<=30 THEN '2.Corto plazo (8-30 DIAS)'
            WHEN lead_time>=31 and lead_time<=90THEN '3.Mediano plazo (1-3 MESES)'
            WHEN lead_time>=91 and lead_time<=180THEN '4.Largo plazo (3-6 MESES)'
            ELSE '5. Muy a largo plazo (> 6 meses)'
            END
ORDER BY hotel, 
         CASE arrival_date_month
              WHEN 'January' THEN 1
              WHEN 'February' THEN 2
              WHEN 'March' THEN 3
              WHEN 'April' THEN 4
              WHEN 'May' THEN 5
              WHEN 'June' THEN 6
              WHEN 'July' THEN 7
              WHEN 'August' THEN 8
              WHEN 'September' THEN 9
              WHEN 'October' THEN 10
              WHEN 'November' THEN 11
              WHEN 'December' THEN 12
          END,
          MIN(lead_time);


---Rendimiento por Canal y Segmento---
SELECT market_segment,
       distribution_channel,
       ROUND(AVG(adr),2)as adr_promedio,
       COUNT(*) AS total_reservas
FROM hotel_bookings
WHERE is_canceled=0 and adr>0and adr< 1000
GROUP BY market_segment,distribution_channel
ORDER BY (AVG(adr)) DESC;



---Factores predictivos de cancelación---

---lead time--
SELECT hotel,
       count(*)as total_reservas_canceladas,
              CASE WHEN lead_time=0 THEN '0.Mismo dia'
                   WHEN lead_time>=1 and lead_time<=7 THEN '1.Sobre la hora (1-7 DIAS)'
                   WHEN lead_time>=8 and lead_time<=30 THEN '2.Corto plazo (8-30 DIAS)'
                   WHEN lead_time>=31 and lead_time<=90THEN '3.Mediano plazo (1-3 MESES)'
                   WHEN lead_time>=91 and lead_time<=180THEN '4.Largo plazo (3-6 MESES)'
              ELSE '5. Muy a largo plazo (> 6 meses)'
              END AS rango_anticipacion
FROM hotel_bookings
WHERE is_canceled=1
GROUP BY hotel,
         CASE WHEN lead_time=0 THEN '0.Mismo dia'
                   WHEN lead_time>=1 and lead_time<=7 THEN '1.Sobre la hora (1-7 DIAS)'
                   WHEN lead_time>=8 and lead_time<=30 THEN '2.Corto plazo (8-30 DIAS)'
                   WHEN lead_time>=31 and lead_time<=90THEN '3.Mediano plazo (1-3 MESES)'
                   WHEN lead_time>=91 and lead_time<=180THEN '4.Largo plazo (3-6 MESES)'
              ELSE '5. Muy a largo plazo (> 6 meses)'
              END
ORDER BY hotel,MIN(lead_time);

---deposit type---
SELECT hotel,
       deposit_type,
       count(*)as total_reservas_canceladas
FROM hotel_bookings
WHERE is_canceled=1
GROUP BY hotel,deposit_type
ORDER BY hotel,count(*)DESC 

--- previus canceled---
SELECT hotel,
       previous_cancellations,
       count(*)as total_reservas_canceladas
FROM hotel_bookings
WHERE is_canceled=1
GROUP BY hotel,previous_cancellations
ORDER BY hotel,previous_cancellations

---country---
WITH cancelaciones_pais as(
SELECT hotel,
       country,
       count(*)as total_ordenes_canceladas,
       ROW_NUMBER()OVER(PARTITION BY hotel ORDER BY count(*) DESC)AS ranking
FROM hotel_bookings
WHERE is_canceled=1
GROUP BY hotel,country
 )
SELECT hotel,
       country,
       total_ordenes_canceladas
FROM cancelaciones_pais
WHERE ranking<=10
ORDER BY hotel,ranking;

---Impacto del tiempo en lista de espera--- 
SELECT 
    hotel,
    CASE 
        WHEN days_in_waiting_list = 0 THEN '0. Sin espera'
        WHEN days_in_waiting_list BETWEEN 1 AND 7 THEN '1. (1-7 DIAS)'
        WHEN days_in_waiting_list BETWEEN 8 AND 30 THEN '2. (8-30 DIAS)'
        WHEN days_in_waiting_list BETWEEN 31 AND 60 THEN '3. (31-60 das)'
        ELSE '4. (mas de 60 dias)'
    END AS Rango_espera,
    COUNT(*) AS total_reservas,
    SUM(CAST(is_canceled AS INT)) AS total_ordenes_canceladas,
    ROUND(AVG(CAST(is_canceled AS FLOAT)) * 100, 2) AS tasa_de_cancelacion
FROM hotel_bookings
GROUP BY 
    hotel,
    CASE 
        WHEN days_in_waiting_list = 0 THEN '0. Sin espera'
        WHEN days_in_waiting_list BETWEEN 1 AND 7 THEN '1. (1-7 DIAS)'
        WHEN days_in_waiting_list BETWEEN 8 AND 30 THEN '2. (8-30 DIAS)'
        WHEN days_in_waiting_list BETWEEN 31 AND 60 THEN '3. (31-60 das)'
        ELSE '4. (mas de 60 dias)'
    END
ORDER BY hotel, Rango_espera;


SELECT hotel, 
       COUNT(*)as Total_Reservas,
      SUM(CASE WHEN reserved_room_type <> assigned_room_type THEN 1 ELSE 0 END) AS Discrepancia_habitaciones,
    ROUND(
        AVG(CASE WHEN reserved_room_type <> assigned_room_type THEN 1.0 ELSE 0.0 END) * 100, 
        2
    ) AS Tasa_discrepancia_pct
FROM hotel_bookings
WHERE is_canceled=0
GROUP BY hotel;



----Requerimientos de servicios----
SELECT hotel,
       CASE 
        WHEN (adults = 0 OR adults IS NULL) 
              AND (children = 0 OR children IS NULL) 
              AND (babies = 0 OR babies IS NULL) 
              THEN 'Sin huéspedes registrados'
        WHEN (adults = 0 OR adults IS NULL) 
              AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
              THEN 'Solo Menores (Anomalía)'
        WHEN adults >= 5 OR children >= 5 OR babies >= 3 
              THEN 'Grupo Grande / Atípico'
        WHEN adults = 1 
             AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
            THEN 'Familia Monoparental'
        WHEN adults BETWEEN 2 AND 4 
             AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
            THEN 'Familia (2+ Adultos con Niños)'
        WHEN adults = 1 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Adulto Solo'
        WHEN adults = 2 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Pareja'
        WHEN adults BETWEEN 3 AND 4 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Grupo de Adultos'
        ELSE 'Otros' 
       END AS composicion_familiar,
       COUNT(*) AS total_reservas,
       SUM(required_car_parking_spaces)as estacionamientos_requeridos,
       SUM(total_of_special_requests)as total_de_requerimientos_especiales,
       ROUND(AVG(CAST(required_car_parking_spaces AS FLOAT)), 3) AS prom_estacionamientos_por_reserva,
       ROUND(AVG(CAST(total_of_special_requests AS FLOAT)), 3) AS prom_solicitudes_por_reserva
FROM hotel_bookings
WHERE is_canceled=0
GROUP BY hotel,
         CASE 
             WHEN (adults = 0 OR adults IS NULL) 
              AND (children = 0 OR children IS NULL) 
              AND (babies = 0 OR babies IS NULL) 
              THEN 'Sin huéspedes registrados'
             WHEN (adults = 0 OR adults IS NULL) 
              AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
              THEN 'Solo Menores (Anomalía)'
             WHEN adults >= 5 OR children >= 5 OR babies >= 3 
              THEN 'Grupo Grande / Atípico'
             WHEN adults = 1 
             AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
            THEN 'Familia Monoparental'
            WHEN adults BETWEEN 2 AND 4 
             AND (ISNULL(children, 0) > 0 OR ISNULL(babies, 0) > 0) 
            THEN 'Familia (2+ Adultos con Niños)'
            WHEN adults = 1 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Adulto Solo'
            WHEN adults = 2 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Pareja'
            WHEN adults BETWEEN 3 AND 4 AND ISNULL(children, 0) = 0 AND ISNULL(babies, 0) = 0 
            THEN 'Grupo de Adultos'
        ELSE 'Otros' 
       END
ORDER BY hotel         
