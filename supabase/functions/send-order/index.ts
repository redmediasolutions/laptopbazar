// Supabase Edge Function: send-order
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const TO_EMAIL = Deno.env.get('ORDER_TO_EMAIL') ?? 'keerthanrao8@gmail.com';
const FROM_NAME = Deno.env.get('ORDER_FROM_NAME') ?? 'ElectraLap Orders';
const FROM_EMAIL = Deno.env.get('ORDER_FROM_EMAIL') ?? 'onboarding@resend.dev'; // Use verified domain here
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (!RESEND_API_KEY) {
      throw new Error('Missing RESEND_API_KEY secret');
    }

    const body = await req.json();
    const { customer = {}, shipping = {}, cart = [], grand_total: grandTotal = 0 } = body;

    // Validation logic...
    if (!customer.email || cart.length === 0) {
      return new Response(JSON.stringify({ error: 'Missing required order data' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Build Email Rows
    const rows = cart
      .map((item: any) => {
        const name = escapeHtml(String(item.name ?? ''));
        const qty = Number(item.qty ?? 0);
        const price = Number(item.unit_price ?? 0);
        const total = Number(item.line_total ?? 0);
        return `
          <tr>
            <td style="padding:8px 0; border-bottom:1px solid #eee;">${name}</td>
            <td style="padding:8px 0; text-align:center; border-bottom:1px solid #eee;">${qty}</td>
            <td style="padding:8px 0; text-align:right; border-bottom:1px solid #eee;">₹${price.toLocaleString('en-IN')}</td>
            <td style="padding:8px 0; text-align:right; border-bottom:1px solid #eee;">₹${total.toLocaleString('en-IN')}</td>
          </tr>`;
      })
      .join('');

    const html = `
      <div style="font-family: sans-serif; max-width: 600px; margin: auto; color: #333;">
        <h2 style="color: #000;">New Order Received</h2>
        <hr />
        <p><strong>Customer:</strong> ${escapeHtml(customer.full_name)} (${customer.phone})</p>
        <p><strong>Shipping Address:</strong><br />
           ${escapeHtml(shipping.address1)}, ${escapeHtml(shipping.city)} - ${escapeHtml(shipping.pincode)}
        </p>
        <table style="width:100%; border-collapse:collapse; margin-top:20px;">
          <thead>
            <tr style="background:#f9fafb;">
              <th style="text-align:left; padding:8px;">Item</th>
              <th style="text-align:center; padding:8px;">Qty</th>
              <th style="text-align:right; padding:8px;">Total</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
        <h3 style="text-align:right;">Grand Total: ₹${Number(grandTotal).toLocaleString('en-IN')}</h3>
      </div>
    `;

    // Send via Resend
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: `${FROM_NAME} <${FROM_EMAIL}>`,
        to: [TO_EMAIL],
        subject: `Order Alert: ${customer.full_name}`,
        html: html,
      }),
    });

    const resData = await res.json();

    if (!res.ok) {
      return new Response(JSON.stringify({ error: 'Resend API error', detail: resData }), {
        status: res.status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ success: true, id: resData.id }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});