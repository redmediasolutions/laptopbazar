// Supabase Edge Function: send-order
// Uses Resend API for email delivery. Set RESEND_API_KEY in Supabase secrets.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const TO_EMAIL = Deno.env.get('ORDER_TO_EMAIL') ?? 'keerthanrao8@gmail.com';
const FROM_NAME = Deno.env.get('ORDER_FROM_NAME') ?? 'ElectraLap Orders';
const FROM_EMAIL = Deno.env.get('ORDER_FROM_EMAIL') ?? 'orders@electralap.in';

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const customer = body?.customer ?? {};
    const shipping = body?.shipping ?? {};
    const cart = Array.isArray(body?.cart) ? body.cart : [];
    const grandTotal = body?.grand_total ?? 0;

    if (!customer.full_name || !customer.email || !customer.phone) {
      return new Response(JSON.stringify({ error: 'Missing customer fields' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (!shipping.address1 || !shipping.city || !shipping.state || !shipping.pincode) {
      return new Response(JSON.stringify({ error: 'Missing shipping fields' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (cart.length === 0) {
      return new Response(JSON.stringify({ error: 'Cart is empty' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const rows = cart
      .map((item: any) => {
        const name = escapeHtml(String(item.name ?? ''));
        const qty = Number(item.qty ?? 0);
        const price = Number(item.unit_price ?? 0);
        const total = Number(item.line_total ?? 0);
        return `
          <tr>
            <td style="padding:8px 0;">${name}</td>
            <td style="padding:8px 0; text-align:center;">${qty}</td>
            <td style="padding:8px 0; text-align:right;">?${price.toLocaleString('en-IN')}</td>
            <td style="padding:8px 0; text-align:right;">?${total.toLocaleString('en-IN')}</td>
          </tr>`;
      })
      .join('');

    const html = `
      <div style="font-family:Arial,sans-serif; line-height:1.5; color:#111827;">
        <h2>New Order</h2>
        <p><strong>Customer</strong></p>
        <p>
          ${escapeHtml(customer.full_name)}<br />
          ${escapeHtml(customer.email)}<br />
          ${escapeHtml(customer.phone)}<br />
          ${customer.gst ? `GST: ${escapeHtml(String(customer.gst))}<br />` : ''}
        </p>
        <p><strong>Shipping</strong></p>
        <p>
          ${escapeHtml(shipping.address1)}<br />
          ${shipping.address2 ? `${escapeHtml(String(shipping.address2))}<br />` : ''}
          ${escapeHtml(shipping.city)}, ${escapeHtml(shipping.state)} - ${escapeHtml(shipping.pincode)}<br />
          ${escapeHtml(shipping.country ?? 'India')}
        </p>
        <p><strong>Order Items</strong></p>
        <table style="width:100%; border-collapse:collapse;">
          <thead>
            <tr>
              <th style="text-align:left; padding:8px 0; border-bottom:1px solid #e5e7eb;">Item</th>
              <th style="text-align:center; padding:8px 0; border-bottom:1px solid #e5e7eb;">Qty</th>
              <th style="text-align:right; padding:8px 0; border-bottom:1px solid #e5e7eb;">Unit Price</th>
              <th style="text-align:right; padding:8px 0; border-bottom:1px solid #e5e7eb;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${rows}
          </tbody>
        </table>
        <p style="margin-top:16px;"><strong>Grand Total:</strong> ?${Number(grandTotal).toLocaleString('en-IN')}</p>
      </div>
    `;

    const text = [
      'New Order',
      '',
      'Customer',
      `${customer.full_name}`,
      `${customer.email}`,
      `${customer.phone}`,
      customer.gst ? `GST: ${customer.gst}` : '',
      '',
      'Shipping',
      `${shipping.address1}`,
      shipping.address2 ? `${shipping.address2}` : '',
      `${shipping.city}, ${shipping.state} - ${shipping.pincode}`,
      `${shipping.country ?? 'India'}`,
      '',
      'Order Items',
      ...cart.map((item: any) => `${item.name} | Qty ${item.qty} | ?${Number(item.line_total ?? 0).toLocaleString('en-IN')}`),
      '',
      `Grand Total: ?${Number(grandTotal).toLocaleString('en-IN')}`,
    ]
      .filter(Boolean)
      .join('\n');

    const resendKey = Deno.env.get('RESEND_API_KEY');
    if (!resendKey) {
      return new Response(JSON.stringify({ error: 'Missing RESEND_API_KEY' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const emailPayload = {
      from: `${FROM_NAME} <${FROM_EMAIL}>`,
      to: [TO_EMAIL],
      subject: `New Order from ${customer.full_name}`,
      html,
      text,
    };

    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${resendKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailPayload),
    });

    if (!resendResponse.ok) {
      const errText = await resendResponse.text();
      return new Response(JSON.stringify({ error: 'Email failed', detail: errText }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: 'Unexpected error', detail: `${err}` }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
