<?php

namespace Zotlabs\Module\Settings;

use Zotlabs\Lib\Apps;

require_once('addon/cart/cart.php');

class Cart {

	function post() {

		if(! local_channel()) {
			return;
		}

		if(! Apps::addon_app_installed(local_channel(), 'cart')) {
			return;
		}

		check_form_security_token_redirectOnErr('settings/cart', 'cart');

		set_pconfig( local_channel(), 'cart', 'enable_test_catalog', intval($_POST['enable_test_catalog'] ));
		set_pconfig( local_channel(), 'cart', 'enable_manual_payments', intval($_POST['enable_manual_payments']) );

		$curcurrency = get_pconfig(local_channel(),'cart','cart_currency');
		$curcurrency = isset($curcurrency) ? $curcurrency : 'USD';
		$currency = substr(preg_replace('[^0-9A-Z]','',$_POST["currency"]),0,3);
		$currencylist=cart_getcurrencies();
		$currency = isset($currencylist[$currency]) ? $currency : 'USD';
		set_pconfig(local_channel(), 'cart','cart_currency', $currency);
		    
		call_hooks('cart_addon_settings_post');

		cart_unload();
		cart_load();

	}

	function get() {

		$id = local_channel();
		if (! $id) {
			return;
		}

		if(! Apps::addon_app_installed(local_channel(), 'cart')) {
			return;
		}

		$testcatalog = get_pconfig ($id,'cart','enable_test_catalog');

		$sc .= replace_macros(get_markup_template('field_checkbox.tpl'), [
			'$field' => [
				'enable_test_catalog',
				t('Enable Test Catalog'),
				(isset($testcatalog) ? $testcatalog : 0),
				'',
				[t('No'),t('Yes')]
			]
		]);

		$manualpayments = get_pconfig ($id,'cart','enable_manual_payments');

		$sc .= replace_macros(get_markup_template('field_checkbox.tpl'), [
			'$field' => [
				'enable_manual_payments',
				t('Enable Manual Payments'),
				(isset($manualpayments) ? $manualpayments : 0),
				'',
				[t('No'),t('Yes')]
			]
		]);

		$currencylist=cart_getcurrencies();
		$currency=get_pconfig(local_channel(), 'cart','cart_currency');
		$saved_currency = isset($currencylist[$currency]) ? $currency : 'USD';

		$currencyoptions = [];

		foreach($currencylist as $c) {
			$currencyoptions[$c["code"]]=$c["code"]." - ".$c["name"];
		}

		$sc .= replace_macros(get_markup_template('field_select.tpl'), [
			'$field' => [
				'currency',
				t('Base Merchant Currency'),
				$saved_currency,
				'',
				$currencyoptions
			]
		]);

		/*
		* @TODO: Set payment options order
		* @TODO: Enable/Disable payment options
		* $paymentopts = Array();
		* call_hooks('cart_paymentopts',$paymentopts);
		* @TODO: Configuure payment options
		*/

		$moresettings = '';
		call_hooks('cart_addon_settings',$moresettings);

		$tpl = get_markup_template("settings_addon.tpl");

		$o = replace_macros($tpl, [
			'$action_url' => 'settings/cart',
			'$form_security_token' => get_form_security_token("cart"),
			'$title' => t('Cart Settings'),
			'$content'  => $sc . $moresettings,
			'$baseurl'   => z_root(),
			'$submit'    => t('Submit'),
		]);

		return $o;

	}

}
