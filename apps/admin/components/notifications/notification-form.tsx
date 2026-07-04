"use client";

import { useState } from "react";

import { Button } from "@/components/ui/button";
import { Card, CardHeader } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/input";

export function NotificationForm() {
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [status, setStatus] = useState("");

  async function handleSend(e: React.FormEvent) {
    e.preventDefault();
    setStatus("Sending…");

    const res = await fetch("/api/notifications/send", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, body }),
    });

    if (res.ok) {
      setStatus("Notification sent");
      setTitle("");
      setBody("");
    } else {
      const data = await res.json();
      setStatus(data.error ?? "Failed to send");
    }
  }

  return (
    <Card>
      <CardHeader title="Send manual notification" />
      <form onSubmit={handleSend} className="space-y-4">
        <div>
          <label className="mb-1 block text-sm font-medium">Title</label>
          <Input value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <label className="mb-1 block text-sm font-medium">Body</label>
          <Textarea value={body} onChange={(e) => setBody(e.target.value)} required />
        </div>
        <Button type="submit">Send to all users</Button>
        {status ? <p className="text-sm text-gray-500">{status}</p> : null}
      </form>
    </Card>
  );
}
