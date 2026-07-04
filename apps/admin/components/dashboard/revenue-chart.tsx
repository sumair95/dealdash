"use client";

import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { Card, CardHeader } from "@/components/ui/card";

type RevenuePoint = { month: string; revenue: number };

export function RevenueChart({ data }: { data: RevenuePoint[] }) {
  return (
    <Card>
      <CardHeader title="Revenue (last 12 months)" description="Premium subscriptions" />
      <div className="h-72">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis dataKey="month" tick={{ fontSize: 12 }} />
            <YAxis tick={{ fontSize: 12 }} />
            <Tooltip formatter={(value) => [`$${value}`, "Revenue"]} />
            <Line
              type="monotone"
              dataKey="revenue"
              stroke="#1B4F72"
              strokeWidth={2}
              dot={{ r: 3 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </Card>
  );
}
