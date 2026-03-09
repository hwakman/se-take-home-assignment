package service

import (
	"testing"

	"github.com/hwakman/se-take-home-assignment/internal/domain"
	"github.com/stretchr/testify/assert"
)

func TestOrderService_OrderFlow(t *testing.T) {
	s := NewOrderService()
	
	// Create order
	order := s.CreateOrder("John", domain.OrderTypeNormal)
	assert.Equal(t, 1, order.ID)
	assert.Equal(t, domain.OrderStatusPending, order.Status)

	// Get order
	o, ok := s.GetOrder(1)
	assert.True(t, ok)
	assert.Equal(t, order, o)

	// List orders
	orders := s.GetAllOrders()
	assert.Equal(t, 1, len(orders))

	// Get queue
	queue := s.GetQueue()
	assert.Equal(t, 1, len(queue))
}

func TestOrderService_BotManagement(t *testing.T) {
	s := NewOrderService()
	
	s.SetBotCount(3)
	assert.Equal(t, 3, len(s.GetBots()))

	s.SetBotCount(1)
	assert.Equal(t, 1, len(s.GetBots()))
}

func TestOrderService_Extra(t *testing.T) {
	s := NewOrderService()
	order := s.CreateOrder("Alice", domain.OrderTypeNormal)
	
	// Test GetQueue before bot starts
	assert.Equal(t, 1, len(s.GetQueue()))

	// Simulate bot picking up the order (Pop from queue, then process)
	popped := s.queue.Pop()
	assert.Equal(t, order.ID, popped.ID)
	assert.Equal(t, 0, len(s.GetQueue()))

	// Test callbacks manually (without bots to avoid race conditions)
	s.HandleOrderStart(order, 1)
	s.HandleOrderComplete(order)
	assert.Equal(t, domain.OrderStatusComplete, order.Status)

	// Create another order and test cancellation (returns it to queue)
	order2 := s.CreateOrder("Bob", domain.OrderTypeNormal)
	assert.Equal(t, 1, len(s.GetQueue()))
	
	// Pop Bob to simulate bot picking it up
	s.queue.Pop()
	assert.Equal(t, 0, len(s.GetQueue()))

	// Cancel Bob (simulates bot being removed mid-processing → order returns to queue)
	s.HandleOrderCancelled(order2)
	assert.Equal(t, 1, len(s.GetQueue()))

	// Test SetBotCount and GetBots separately (no pending work to cause races)
	s2 := NewOrderService()
	s2.SetBotCount(1)
	assert.Equal(t, 1, len(s2.GetBots()))
}
