-- query_id: quicksight
-- query_description: This query will provide monthly unblended and usage information per linked account for Amazon QuickSight.
-- query_columns: bill_payer_account_id,line_item_usage_account_id,month_line_item_usage_start_date,purchase_type_line_item_usage_type,sum_line_item_usage_amount,sum_line_item_unblended_cost
-- query_link: /cost/300_labs/300_cur_queries/queries/analytics/

 SELECT -- automation_select_stmt
    bill_payer_account_id,
    line_item_usage_account_id,
    DATE_FORMAT(line_item_usage_start_date,'%Y-%m') AS month_line_item_usage_start_date, -- automation_timerange_dateformat
    CASE 
        WHEN LOWER(line_item_usage_type) LIKE 'qs-user-enterprise%' THEN 'Users - Enterprise'
        WHEN LOWER(line_item_usage_type) LIKE 'qs-user-standard%' THEN 'Users - Standard'
        WHEN LOWER(line_item_usage_type) LIKE 'qs-reader-usage%' THEN 'Reader Usage'
        WHEN LOWER(line_item_usage_type) LIKE '%spice' THEN 'SPICE'  
        ELSE line_item_usage_type
    END as purchase_type_line_item_usage_type,
    SUM(CAST(line_item_usage_amount AS double)) AS sum_line_item_usage_amount,
    SUM(CAST(line_item_unblended_cost AS decimal(16,8))) AS sum_line_item_unblended_cost
FROM -- automation_from_stmt
     ${table_name} -- automation_tablename
WHERE -- automation_where_stmt
   year = '2020' AND (month BETWEEN '7' AND '9' OR month BETWEEN '07' AND '09') -- automation_timerange_year_month
   AND product_product_name = 'Amazon QuickSight'
   AND line_item_line_item_type  in ('DiscountedUsage', 'Usage', 'SavingsPlanCoveredUsage')
GROUP BY -- automation_groupby_stmt
   bill_payer_account_id,
   line_item_usage_account_id,
   DATE_FORMAT(line_item_usage_start_date,'%Y-%m'), -- automation_timerange_dateformat
   CASE 
      WHEN LOWER(line_item_usage_type) LIKE 'qs-user-enterprise%' THEN 'Users - Enterprise'
      WHEN LOWER(line_item_usage_type) LIKE 'qs-user-standard%' THEN 'Users - Standard'
      WHEN LOWER(line_item_usage_type) LIKE 'qs-reader-usage%' THEN 'Reader Usage'
      WHEN LOWER(line_item_usage_type) LIKE '%spice' THEN 'SPICE'  
      ELSE line_item_usage_type
   END
ORDER BY -- automation_order_stmt
   month_line_item_usage_start_date,
   sum_line_item_unblended_cost DESC;
