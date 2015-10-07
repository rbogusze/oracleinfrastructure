SELECT *
FROM
(select PO_HEADER_ID, PO_RELEASE_ID, PO_NUMBER, PO_NUMBER_DISP,RELEASE_NUMBER, REV_NUMBER, TYPE_LOOKUP_CODE, LINE_ID, LINE_NUMBER, SHIPMENT_ID, SHIPMENT_NUMBER, ORDER_QTY,UNIT_PRICE, PO_AMOUNT, NEED_DATE, PROMISE_DATE, BUYER_ID, CURRENCY, APPROVED_DATE, STATUS, BUYER, ITEM_DESCRIPTION, ORG_ID, UOM, SHIP_TO_LOCATION, ITEM_NUM, ITEM_REVISION, VENDOR_ID, VENDOR_SITE_ID, VENDOR_CONTACT_ID,CREATION_DATE,OTM_PLANED,PROMISE,ORG_CODE
from gems_po.GE_PO_GLOBAL_REPROMISE_V) QRSLT
WHERE (vendor_id in
(select k.number_value
from ak_web_user_sec_attr_values k
where attribute_code = 'ICX_SUPPLIER_ORG_ID' AND attribute_application_id = 177 AND web_user_id = 390352) And vendor_id || vendor_site_id || vendor_contact_id IN
(Select supplier.NUMBER_VALUE || NVL(site.NUMBER_VALUE, vendor_site_id) || NVL(contact.NUMBER_VALUE, vendor_contact_id)
From
(SELECT *
FROM AK_WEB_USER_SEC_ATTR_VALUES
WHERE WEB_USER_ID = 390352 AND attribute_code = 'ICX_SUPPLIER_ORG_ID' AND attribute_application_id = 177) supplier,
(SELECT *
FROM AK_WEB_USER_SEC_ATTR_VALUES
WHERE WEB_USER_ID = 390352 AND attribute_code = 'ICX_SUPPLIER_SITE_ID' AND attribute_application_id = 177) site,
(SELECT *
FROM AK_WEB_USER_SEC_ATTR_VALUES
WHERE WEB_USER_ID = 390352 AND attribute_code = 'ICX_SUPPLIER_CONTACT_ID' AND attribute_application_id = 177) contact
where supplier.WEB_USER_ID = site.WEB_USER_ID(+) and site.WEB_USER_ID = contact.WEB_USER_ID(+)) AND trunc(Need_Date) >= trunc(to_date('01-Jan-2015')) AND trunc(Need_Date) <= trunc(to_date('31-Dec-2015'))) ORDER BY Approved_Date desc, PO_Number, Line_Number, Shipment_Number
;
