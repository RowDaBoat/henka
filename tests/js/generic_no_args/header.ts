export interface MessageEvent<T = any> {
  data: T
  origin: string
}

export interface Channel {
  message: MessageEvent
  source: MessageEvent<string>
}
