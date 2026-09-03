<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_countries_endpoint(): void
    {
        $this->seed();

        $response = $this->getJson('/api/countries');

        $response->assertOk()->assertJsonStructure(['data']);
        $this->assertGreaterThanOrEqual(12, count($response->json('data')));
    }

    public function test_demo_login_and_transfer(): void
    {
        $this->seed();

        $login = $this->postJson('/api/login', [
            'phone' => '0700000001',
            'password' => 'password',
        ]);

        $login->assertOk();
        $token = $login->json('token');

        $transfer = $this->withToken($token)->postJson('/api/transfers', [
            'recipient_phone' => '0700000002',
            'amount' => 2500,
            'sender_operator' => 'orange_money',
            'recipient_operator' => 'wave',
            'destination_country' => 'SN',
        ]);

        $transfer->assertCreated();
        $this->assertEquals('completed', $transfer->json('transfer.status'));
    }
}
