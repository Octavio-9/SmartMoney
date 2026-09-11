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

    public function test_billers_follow_the_account_country(): void
    {
        $this->seed();

        $guinee = $this->billerCodes('0700000004');
        foreach (['edg', 'seg', 'orange_gn', 'mtn_gn', 'cellcom_gn', 'canal_plus', 'startimes'] as $code) {
            $this->assertContains($code, $guinee);
        }
        $this->assertNotContains('sodeci', $guinee);

        // Sans cela, le garde Sanctum garde en cache le premier utilisateur.
        $this->app['auth']->forgetGuards();

        $ivoirien = $this->billerCodes('0700000001');
        $this->assertContains('sodeci', $ivoirien);
        $this->assertNotContains('edg', $ivoirien);
    }

    private function billerCodes(string $phone): array
    {
        $token = $this->postJson('/api/login', ['phone' => $phone, 'password' => 'password'])
            ->assertOk()
            ->json('token');

        return collect($this->withToken($token)->getJson('/api/billers')->assertOk()->json('data'))
            ->pluck('code')
            ->all();
    }
}
