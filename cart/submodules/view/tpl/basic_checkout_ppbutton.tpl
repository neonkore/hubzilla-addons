<script src="https://www.paypalobjects.com/api/checkout.js"></script>
<center><h1>INVOICE</h1>
<h4>ORDER: {{$order_hash}}</h4>
</center>

{{include file="../../../view/tpl/basic_cart.tpl"}}

{{if !$order.checkedout}}

<div id="paypal-button"></div>

<script>
  paypal.Button.render({
    env: '{{$paypalenv}}',
    payment: function(data, actions) {
      return actions.request.post('{{$buttonhook}}_create')
        .then(function(res) {
          return res.id;
        });
    },
    onAuthorize: function(data, actions) {
      return actions.request.post('{{$buttonhook}}_execute', {
        paymentID: data.paymentID,
        payerID:   data.payerID
      }).then(function () {window.location = '{{$finishedurl}}';});
    }
  }, '#paypal-button');
</script>
{{else}}
<h3>This order has been confirmed and is awaiting payment.</h3>
<h4><a href="{{$finishedurl}}">{{$finishedtext}}</a></h4>
{{/if}}
